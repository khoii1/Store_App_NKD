import 'package:flutter/material.dart';
import 'package:mac_store_app/views/screens/nav_screen/widgets/banner_widget.dart';
import 'package:mac_store_app/views/screens/nav_screen/widgets/category_item_widget.dart';
import 'package:mac_store_app/views/screens/nav_screen/widgets/header_widget.dart';
import 'package:mac_store_app/views/screens/nav_screen/widgets/popular_product_widget.dart';
import 'package:mac_store_app/views/screens/nav_screen/widgets/reusable_text_widget.dart';
import 'package:mac_store_app/views/screens/nav_screen/widgets/top_rated_product_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.20,
        ),
        child: const HeaderWidget(),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            BannerWidget(),
            CategoryItemWidget(),

            ReusableTextWidget(
              title: 'Top Rated Products',
              subtitle: 'View all',
            ),
            TopRatedProductWidget(),
            ReusableTextWidget(
              title: 'Popular Products',
              subtitle: ' View All',
            ),
            PopularProductWidget(),
          ],
        ),
      ),
    );
  }
}
