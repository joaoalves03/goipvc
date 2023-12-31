import 'package:flutter/material.dart';
import 'package:goipvc/models/sas/meal.dart';
import 'package:goipvc/ui/widgets/default_meal.dart';

class MealCard extends StatelessWidget {
  final SASMeal meal;

  const MealCard({
    super.key,
    required this.meal
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              Row(
                  children: [
                    Expanded(
                      child:
                      meal.imageUrl != null
                        ? Image.network(
                          meal.imageUrl!,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (_, __, ___) {
                            return const DefaultMealImage();
                          },
                        )
                        : const DefaultMealImage()
                    )
                  ]
              ),
              Row(
                  children: [
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  meal.type,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  )
                              ),
                              Text(
                                  meal.name,
                                  style: const TextStyle(
                                      fontSize: 16
                                  )
                              )
                            ],
                          ),
                        )
                    )
                  ]
              ),
            ],
          ),
          Container(
            width: double.infinity, // Set the width to use all horizontal space
            height: 30,
            color: meal.available
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                meal.available
                  ? "${meal.price.toString()}€"
                  : "Indisponível",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                )
              ),
            )
          )
        ],
      )
    );
  }
}