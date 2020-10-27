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

## 1. Запуск Krouter [worker.rb](./example/worker.rb)

```sh
docker-compose run worker
```

[work.rb](./example/work.rb) выполняются действия:

1. Добавляются монады в `actions`
2. Задаётся общий домен `vk`
3. Запускается роутер

## 2. Генерация сообщений [creator.rb](./example/creator.rb)

```sh
docker-compose run creator
```

[create.rb](./example/creator.rb) отправляет случайные сообщения в топики:
- `vk.items.create_template-create`
- `vk.items.templates-get`

## 3. Просмотр результата [receiver.rb](./example/receiver.rb)

```sh
docker-compose run receiver
```

[receive.rb](./example/receive.rb) выводит сообщения с топиков:
  
- `vk.items.templates-receive`
- `vk.items.create_template-receive`
