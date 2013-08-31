# Proof-of-concept scribbles.
require 'green_shoes'

# Damn, for some strange reason this doesn't work:
fiber = Fiber.new do
  Fiber.yield 1
  Fiber.yield 2
end

Shoes.app do
  @p = para 'initial'
  button 'click' do
    @p = para fiber.resume
  end
end
