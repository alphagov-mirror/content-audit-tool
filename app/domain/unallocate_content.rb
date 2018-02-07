class UnallocateContent
  def self.call(*args)
    new(*args).call
  end

  attr_accessor :content_ids

  def initialize(content_ids:)
    self.content_ids = content_ids
  end

  def call
    deleted_items = Allocation.where(content_id: content_ids).delete_all

    AllocationResult.new("no one", deleted_items)
  end
end
