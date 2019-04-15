class Kkuleomi::Store::Suggester
  def initialize(q)
    @q = q
  end

  def execute!(*repositories)
    @response ||= []
    repositories.each do |respository|
      @response << begin
        repository.client.suggest(index: repository.index_name,
          body: repository.suggest_body(@term))
      end
    end
  end
end