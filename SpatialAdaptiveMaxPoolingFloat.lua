require 'nn'

local ffi = require 'ffi'

ffi.cdef[[
void SpatialAdaptiveMaxPooling_updateOutput_frame(float *input_p,
                                                      float *output_p,
                                                      //real *indx_p, real *indy_p,
                                                      long nslices,
                                                      long iwidth, long iheight,
                                                      long owidth, long oheight);

]]

local C = ffi.load '/opt/torch7/torch-nn/build/libadapt.so'
--local C = ffi.load 'build/libadapt.so'
--local C = ffi.load(package.searchpath('libadapt', package.cpath))

local SpatialAdaptiveMaxPoolingFloat, parent = torch.class('nn.SpatialAdaptiveMaxPoolingFloat', 'nn.Module')

function SpatialAdaptiveMaxPoolingFloat:__init(W, H)
  parent.__init(self)
  
  self.W = W
  self.H = H or W
  
  self.output = torch.Tensor()
  self.gradInput = torch.Tensor()
  
  self.indices = torch.Tensor()
end

function SpatialAdaptiveMaxPoolingFloat:updateOutput(input)
  local dimw = 3
  local dimh = 2
  local nslices = input:size(1)
  if input:nDimension() == 4 then 
    dimw = dimw + 1
    dimh = dimh + 1
    self.output:resize(input:size(1),input:size(2),self.H,self.W)
    nslices = nslices*input:size(2)
  else
    self.output:resize(input:size(1),self.H,self.W)
  end
  
  
  assert(input:size(dimw)>=self.W, "input width should be greater or equal than W")
  assert(input:size(dimh)>=self.H, "input height should be greater or equal than H")
  
  local input = input
  if not input:isContiguous() then
    input = input:contiguous()
  end
 
  C['SpatialAdaptiveMaxPooling_updateOutput_frame'](input:data(), self.output:data(), nslices, input:size(dimw), input:size(dimh), self.W, self.H)  
  
  return self.output

end

function SpatialAdaptiveMaxPoolingFloat:updateGradInput(input, gradOutput)
  error('Not yet implemented')
end
