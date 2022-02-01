import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCardSkelton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
         const Skeleton(height: 60, width: 80),
         const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Skeleton(width: 80, height: 10),
                const SizedBox(height: 16.0 / 2),
                Row(
                  children:const [
                     Skeleton(
                      width: 100,
                      height: 20,
                    ),
                    Spacer(),
                    Skeleton(height: 20, width: 20)
                  ],
                ),
                const SizedBox(height: 16.0 / 2),
                Row(
                  children: const [
                    Expanded(
                      child: Skeleton(
                        height: 20,
                        width: 10,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}


class Shimmerku extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: Colors.grey,
        highlightColor: Colors.grey[300]!,
        period: Duration(seconds: 2),
        child: Container(
          width: 10,
          height: 10,
          decoration: ShapeDecoration(
            color: Colors.grey[400],
            shape: CircleBorder(),
          ),
        ),
      );
}


class Skeleton extends StatelessWidget {
  const Skeleton({ required this.height, required this.width});
  final double height, width;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.6),
            borderRadius: const BorderRadius.all(Radius.circular(16.0))),
      ),
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.grey[100]!);
}