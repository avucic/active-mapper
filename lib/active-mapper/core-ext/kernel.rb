module Kernel

	private

	raise NameError.new "ActiveMapper detect that Kernel method repository is already defined by some other library." if respond_to?(:repository)

	def repository(*args, &block)
		ActiveMapper.repository(*args, &block)
	end
end # module Kernel
