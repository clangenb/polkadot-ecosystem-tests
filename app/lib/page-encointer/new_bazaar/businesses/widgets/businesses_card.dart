import 'dart:convert';

import 'package:encointer_wallet/gen/assets.gen.dart';
import 'package:encointer_wallet/page-encointer/new_bazaar/single_business/logic/single_business_store.dart';
import 'package:encointer_wallet/page-encointer/new_bazaar/single_business/views/single_business_view.dart';
import 'package:encointer_wallet/utils/extensions/string/string_extensions.dart';
import 'package:flutter/material.dart';

import 'package:encointer_wallet/models/bazaar/businesses.dart';
import 'package:encointer_wallet/theme/theme.dart';
import 'package:provider/provider.dart';

class BusinessesCard extends StatelessWidget {
  const BusinessesCard({super.key, required this.businesses});

  final Businesses businesses;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return InkWell(
      onTap: () {
        Navigator.push<Widget>(
          context,
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => SingleBusinessStore(businesses)..getSingleBusiness(),
              child: const SingleBusinessView(),
            ),
          ),
        );
      },
      child: SizedBox(
        height: 160,
        child: Card(
          margin: const EdgeInsets.only(top: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (businesses.logo.isNotNullOrEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(businesses.logo!),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: const SizedBox(height: double.infinity, width: 130),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(Assets.images.assets.mosaicBackground.path),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: const SizedBox(height: double.infinity, width: 130),
                ),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(businesses.category.name, style: textTheme.bodySmall)),
                      Text(
                        businesses.status?.name ?? '',
                        style: textTheme.bodySmall!.copyWith(color: businesses.status?.textColor ?? Colors.black),
                      )
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      Text(
                        utf8convert(businesses.name),
                        style: textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        utf8convert(businesses.description),
                        style: textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// To display, correctly, german names coming from server
  String utf8convert(String text) {
    final bytes = text.codeUnits;
    return utf8.decode(bytes);
  }
}
