require 'cunn'

dofile 'SpatialAdaptiveMaxPooling.lua'

input = torch.Tensor(32, 3, 58, 40):cuda()

module = nn.SpatialAdaptiveMaxPooling(4,4):cuda()

print(module:forward(input):size())
