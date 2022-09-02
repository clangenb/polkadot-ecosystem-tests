import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page/assets/account_or_community/account_or_community_data.dart';
import 'package:flutter/material.dart';

class AccountOrCommunityItemHorizontal extends StatefulWidget {
  final AccountOrCommunityData itemData;
  final int index;
  final Function? onTap;

  const AccountOrCommunityItemHorizontal({
    Key? key,
    required this.itemData,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AccountOrCommunityItemHorizontal> createState() => _AccountOrCommunityItemHorizontalState();
}

class _AccountOrCommunityItemHorizontalState extends State<AccountOrCommunityItemHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => widget.onTap!(widget.index),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(width: 2, color: widget.itemData.isSelected ? ZurichLion.shade500 : Colors.transparent),
            ),
            child: widget.itemData.avatar,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            widget.itemData.name!,
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}