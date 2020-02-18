import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/txDetail.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TransferDetail extends StatelessWidget {
  TransferDetail(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).assets;
    final String symbol = store.settings.networkState.tokenSymbol;
    final int decimals = store.settings.networkState.tokenDecimals;
    final TransferData tx = store.assets.txDetail;
    final BlockData block = store.assets.blockMap[tx.block];

    final String txType = tx.sender == store.account.currentAccount.address
        ? dic['transfer']
        : dic['receive'];

    return TxDetail(
      success: true,
      action: txType,
      eventId: tx.id,
      block: block,
      info: <DetailInfoItem>[
        DetailInfoItem(
          label: dic['value'],
          title:
              '${Fmt.token(tx.value, decimals: decimals, fullLength: true)} $symbol',
        ),
        DetailInfoItem(
          label: dic['fee'],
          title:
              '${Fmt.token(tx.fee, decimals: decimals, fullLength: true)} $symbol',
        ),
        DetailInfoItem(
          label: dic['from'],
          title: tx.senderId,
          subtitle: Fmt.address(tx.sender),
          address: tx.sender,
        ),
        DetailInfoItem(
          label: dic['to'],
          title: tx.destinationId,
          subtitle: Fmt.address(tx.destination),
          address: tx.destination,
        )
      ],
    );
  }
}