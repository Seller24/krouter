# Krouter – Kafka Router

Роутер для связи микросервисов с главным приложением.

## Интеграция

```ruby
require 'krouter'

include Import[
  'action.list',
  'action.create'
]

Krouter::Krouter.new(
  domain: 'vk',
  actions: [list, create]
).call
```

# Проверка работы

Запустить в разных окнах терминала:

## 1. Запуск Krouter [work.rb](./example/work.rb)

```sh
docker-compose run play-work
```

[work.rb](./example/work.rb) выполняются действия:

1. Добавляются монады в `actions`
2. Задаётся общий домен `vk`
3. Запускается роутер

## 2. Генерация сообщений [create.rb](./example/create.rb)

```sh
docker-compose run play-create
```

[create.rb](./example/create.rb) отправляет случайные сообщения в топики:
- `vk.items.create_template-create`
- `vk.items.templates-get`

## 3. Просмотр результата [receive.rb](./example/receive.rb)

```sh
docker-compose run play-receive
```

[receive.rb](./example/receive.rb) выводит сообщения с топиков:
  
- `vk.items.templates-receive`
- `vk.items.create_template-receive`
