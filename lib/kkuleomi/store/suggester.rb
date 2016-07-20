class Kkuleomi::Store::Suggester
  def initialize(q)
    @q = q
  end

  def response
    @response ||= begin
      Elasticsearch::Persistence.client.suggest(
          index: "packages-#{Rails.env}",
          body: {
              name: {
                  text: @q,
                  completion: { field: 'suggest_name', size: 25 }
              },
              description: {
                  text: @q,
                  completion: { field: 'suggest_description', size: 25 }
              }
          }
      )
    end
  end
end