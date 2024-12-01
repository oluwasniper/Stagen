# Models Directory

This directory contains the data models used in the `revolutionary_stuff` project. Each model represents a specific entity and its attributes, which are used throughout the application.

## Contents

- `user.dart`: Defines the `User` model, which includes attributes like `id`, `name`, `email`, and `password`.
- `product.dart`: Defines the `Product` model, which includes attributes like `id`, `name`, `description`, `price`, and `stock`.
- `order.dart`: Defines the `Order` model, which includes attributes like `id`, `userId`, `productId`, `quantity`, and `totalPrice`.

## Usage

To use any of these models, simply import the desired model file into your Dart code:

```dart
import 'package:revolutionary_stuff/models/user.dart';
import 'package:revolutionary_stuff/models/product.dart';
import 'package:revolutionary_stuff/models/order.dart';
```

## Contributing

If you wish to contribute to the models, please ensure that:

1. Each model is defined in its own file.
2. The model includes all necessary attributes and methods.
3. The model is well-documented with comments.
