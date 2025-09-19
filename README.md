# OwmSdk

**OwmSdk** é um SDK Ruby leve para a [API OpenWeatherMap](https://openweathermap.org/forecast5), focado em obter dados de previsão do tempo (`/forecast`).  
Ele permite recuperar facilmente informações de previsão fornecendo apenas o *city ID*.

## Instalação

Adicione esta linha ao seu `Gemfile`:

```bash
bundle add owm_sdk
```

Se não estiver usando Bundler, instale diretamente com:

```bash
gem install owm_sdk
```

## Uso

Inicialização básica

```ruby

require "owm_sdk"

client = OwmSdk::Client.new(api_key: ENV.fetch("OPEN_WEATHER_MAP_API_KEY"))
resultado = client.fetch(3448439) # city_id (ex.: São Paulo)
```

O método fetch(city_id) retorna um Hash com uma estrutura simplificada:

```ruby

{
  city: "São Paulo",
  current: {
    temp: 16.52,
    description: "nuvens dispersas",
    date: "2025-09-18 03:00:00"
  },
  daily_average: {
    "2025-09-18" => 20.06,
    "2025-09-19" => 21.50,
    # ...
  }
}
```

Opções de inicialização

É possível customizar o comportamento para integração ou testes:

```ruby
# passando timeout, base URL ou uma conexão Faraday já existente
client = OwmSdk::Client.new(
  api_key: "XYZ123",
  timeout: 10,
  base: "https://api.openweathermap.org/data/2.5",
  conn: conexao_faraday_customizada
)

```

### Observações

* As temperaturas retornadas estão em Celsius (units=metric).

* As descrições climáticas são retornadas em português (lang=pt_br).

* O campo daily_average agrupa as leituras por data (YYYY-MM-DD) e calcula a média aritmética das temperaturas daquele dia, arredondada com 2 casas decimais.

* A resposta do SDK é propositalmente simplificada para facilitar a integração com aplicações.

### Exemplo de integração com Rails

Dentro de um service/adapter (ex.: WeatherClient):

```ruby
class WeatherClient
  def initialize(api_key: ENV["OPEN_WEATHER_MAP_API_KEY"], client: nil)
    @client = client || OwmSdk::Client.new(api_key: api_key)
  end

  def fetch(city_id)
    @client.fetch(city_id)
  end
end
```

Bug reports and pull requests are welcome on GitHub at <https://github.com/Paulo-Rodrigues/owm_sdk>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
