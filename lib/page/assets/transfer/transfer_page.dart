import 'package:encointer_wallet/common/components/address_input_field.dart';
import 'package:encointer_wallet/common/components/encointer_text_form_field.dart';
import 'package:encointer_wallet/common/components/gradient_elements.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/models/communities/community_identifier.dart';
import 'package:encointer_wallet/page-encointer/common/community_chooser_panel.dart';
import 'package:encointer_wallet/page/assets/transfer/payment_confirmation_page/index.dart';
import 'package:encointer_wallet/page/qr_scan/qr_scan_page.dart';
import 'package:encointer_wallet/service/substrate_api/api.dart';
import 'package:encointer_wallet/store/account/types/account_data.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:encointer_wallet/utils/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class TransferPageParams {
  TransferPageParams({
    this.cid,
    this.communitySymbol,
    this.recipient,
    this.label,
    this.amount,
    this.redirect,
  });

  final CommunityIdentifier? cid;
  final String? communitySymbol;
  final String? recipient;
  final String? label;
  final double? amount;
  final String? redirect;
}

class TransferPage extends StatefulWidget {
  TransferPage({Key? key}) : super(key: key);

  static const String route = '/assets/transfer';

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  late final _appStore;

  final TextEditingController _amountCtrl = TextEditingController();

  AccountData? _accountTo;

  @override
  void initState() {
    super.initState();
    _appStore = context.read<AppStore>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final TransferPageParams args = ModalRoute.of(context)!.settings.arguments as TransferPageParams;
      if (args.amount != null) {
        _amountCtrl.text = '${args.amount}';
      }

      if (args.recipient != null) {
        final AccountData acc = AccountData();
        acc.address = args.recipient!;
        acc.name = args.label!;
        setState(() {
          _accountTo = acc;
        });
      } else {
        if (_appStore.account.optionalAccounts.length > 0) {
          setState(() {
            _accountTo = _appStore.account.optionalAccounts[0];
          });
        } else if (_appStore.settings.contactList.length > 0) {
          setState(() {
            _accountTo = _appStore.settings.contactList[0];
          });
        }
      }

      webApi.fetchAccountData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context)!.translationsForLocale();
    TransferPageParams params = ModalRoute.of(context)!.settings.arguments as TransferPageParams;
    final _store = context.watch<AppStore>();

    var communitySymbol = params.communitySymbol ?? _store.encointer.community!.symbol!;
    var cid = params.cid ?? _store.encointer.chosenCid!;

    int decimals = encointer_currencies_decimals;

    double? available = _store.encointer.applyDemurrage(_store.encointer.communityBalanceEntry);

    print('[transferPage]: available: $available');

    return Observer(
      builder: (_) {
        return Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              title: Text(dic.assets.transfer),
              leading: Container(),
              actions: [
                IconButton(
                  key: const Key('close-transfer-page'),
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        CombinedCommunityAndAccountAvatar(_appStore, showCommunityNameAndAccountName: false),
                        const SizedBox(height: 12),
                        _store.encointer.communityBalance != null
                            ? AccountBalanceWithMoreDigits(
                                store: _store,
                                available: available,
                                decimals: decimals,
                              )
                            : const CupertinoActivityIndicator(),
                        Text(
                          I18n.of(context)!.translationsForLocale().assets.yourBalanceFor.replaceAll(
                                'ACCOUNT_NAME',
                                Fmt.accountName(context, _store.account.currentAccount),
                              ),
                          style: Theme.of(context).textTheme.headline4!.copyWith(color: encointerGrey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        IconButton(
                          iconSize: 48,
                          icon: const Icon(Iconsax.scan_barcode),
                          onPressed: () => Navigator.of(context).popAndPushNamed(
                            ScanPage.route,
                            arguments: ScanPageParams(scannerContext: QrScannerContext.transferPage),
                          ), // same as for clicking the scan button in the bottom bar
                        ),
                        const SizedBox(height: 24),
                        EncointerTextFormField(
                          labelText: dic.assets.amountToBeTransferred,
                          textStyle: Theme.of(context).textTheme.headline1!.copyWith(color: encointerBlack),
                          inputFormatters: [UI.decimalInputFormatter(decimals: decimals)],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: _amountCtrl,
                          textFormFieldKey: const Key('transfer-amount-input'),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return dic.assets.amountError;
                            }
                            if (balanceTooLow(value, available!, decimals)) {
                              return dic.assets.insufficientBalance;
                            }
                            return null;
                          },
                          suffixIcon: const Text('ⵐ', style: TextStyle(color: encointerGrey, fontSize: 44)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: AddressInputField(
                                _store,
                                label: dic.assets.address,
                                initialValue: _accountTo,
                                onChanged: (AccountData acc) {
                                  setState(() {
                                    _accountTo = acc;
                                  });
                                },
                                hideIdenticon: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _store.settings.developerMode
                      ? Center(
                          child: Text(
                            '${dic.assets.fee}: TODO compute Fee', // TODO compute fee #589
                            style: Theme.of(context).textTheme.headline4!.copyWith(color: encointerGrey),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    key: const Key('make-transfer'),
                    child: SizedBox(
                      height: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.login_1),
                          const SizedBox(width: 12),
                          Text(dic.account.next),
                        ],
                      ),
                    ),
                    onPressed: _accountTo != null ? () => _pushPaymentConfirmationPage(cid, communitySymbol) : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _pushPaymentConfirmationPage(CommunityIdentifier cid, String communitySymbol) {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(
        context,
        PaymentConfirmationPage.route,
        arguments: PaymentConfirmationParams(
            cid: cid,
            communitySymbol: communitySymbol,
            recipientAccount: _accountTo!,
            amount: double.parse(_amountCtrl.text.trim())),
      );
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  bool balanceTooLow(String v, double available, int decimals) {
    return double.parse(v.trim()) >= available;
  }
}

class AccountBalanceWithMoreDigits extends StatelessWidget {
  const AccountBalanceWithMoreDigits({
    Key? key,
    required this.store,
    required this.available,
    required this.decimals,
  }) : super(key: key);

  final AppStore store;
  final double? available;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        // need text base line alignment
        text: TextSpan(
          text: '${Fmt.doubleFormat(
            available,
            length: 6,
          )} ',
          style: Theme.of(context).textTheme.headline2!.copyWith(color: encointerBlack),
          children: const <TextSpan>[
            TextSpan(
              text: 'ⵐ',
              style: TextStyle(color: encointerGrey),
            ),
          ],
        ),
      ),
    );
  }
}