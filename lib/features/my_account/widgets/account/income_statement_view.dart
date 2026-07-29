import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/paginated_list_view_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/controllers/my_account_controller.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/delivery_income_statement_model.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/delivery_income_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/pricing_card.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/ride_income_bottom_sheet.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/models/trip_details_model.dart';
import 'package:sixam_mart_delivery/features/ride_module/trip/domain/models/trip_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class Income {
  String title;
  String image;
  double amount;

  Income({required this.title, required this.image, required this.amount});
}

class IncomeStatementView extends StatefulWidget {

  const IncomeStatementView({super.key});

  @override
  State<IncomeStatementView> createState() => _IncomeStatementViewState();
}

class _IncomeStatementViewState extends State<IncomeStatementView> {

  final ScrollController scrollController = ScrollController();

  List<Income> incomeList = [];

  int _selectedIndex = 0;

  bool isActiveDelivery = (Get.find<ProfileController>().profileModel?.isDeliveryOn ?? false);
  bool isActiveRide = (Get.find<ProfileController>().profileModel?.isRideOn ?? false);

  @override
  void initState() {
    super.initState();

    var profileModel = Get.find<ProfileController>().profileModel;
    incomeList = [
      Income(title: 'total_earning'.tr, image: Images.totalEarning, amount: profileModel?.totalEarning ?? 0),
      Income(title: 'total_income'.tr, image: Images.totalIncome, amount: profileModel?.totalIncome ?? 0),
      if(isActiveRide && isActiveDelivery) Income(title: 'ride_income'.tr, image: Images.rideIncome, amount:profileModel?.tripIncome ?? 0),
      if(isActiveRide && isActiveDelivery) Income(title: 'delivery_income'.tr, image: Images.deliveryIncome, amount: profileModel?.deliveryIncome ?? 0),
      Income(title: 'total_tips'.tr, image: Images.totalTips, amount:profileModel?.totalTips ?? 0),
    ];

    _selectedIndex = isActiveRide ? 1 : 0;
  }

  void _changeTabIndex(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<MyAccountController>(builder: (transactionController){
        return SingleChildScrollView(
          controller : scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
              child: Text("income_statements".tr, style: robotoBold),
            ),

            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: incomeList.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return PricingCard(
                    image: incomeList[index].image,
                    title: incomeList[index].title,
                    amount: incomeList[index].amount,
                  );
                },
              ),
            ),

            isActiveDelivery && isActiveRide ? Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(children: [

                InkWell(
                  onTap: () {
                    if(_selectedIndex != 0) {
                      _changeTabIndex(0);
                    }
                  },
                  hoverColor: Colors.transparent,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text('delivery_statement'.tr, style: robotoMedium.copyWith(
                      color: _selectedIndex == 0 ?  Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    )),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Container(
                      height: 3, width: 110,
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: _selectedIndex == 0 ?  Theme.of(context).primaryColor: null,
                      ),
                    ),

                  ]),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                InkWell(
                  onTap: () {
                    if(_selectedIndex != 1) {
                      _changeTabIndex(1);
                    }
                  },
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text('ride_statement'.tr, style: robotoMedium.copyWith(
                      color: _selectedIndex == 1 ?  Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    )),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Container(
                      height: 3, width: 150,
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: _selectedIndex == 1 ? Theme.of(context).primaryColor : null,
                      ),
                    ),

                  ]),
                ),
              ]),
            ) : const SizedBox(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text("transaction_history".tr, style: robotoBold),
            ),

            _selectedIndex == 1
                ? _RideStatementPaginatedView(transactionController, scrollController)
                : _DeliveryStatementPaginatedView(transactionController, scrollController)

          ]),
        );
      }),
    );
  }
}


class _RideStatementPaginatedView extends StatelessWidget {
  final MyAccountController transactionController;
  final ScrollController scrollController;
  const _RideStatementPaginatedView(this.transactionController, this.scrollController);

  @override
  Widget build(BuildContext context) {

    TripModel? tripModel = transactionController.rideIncomeStatement;

    return tripModel != null && tripModel.tripList != null && tripModel.tripList!.isNotEmpty ? PaginatedListViewWidget(
      scrollController: scrollController,
      totalSize: transactionController.rideIncomeStatement?.totalSize,
      offset: transactionController.rideIncomeStatement?.offset,
      onPaginate: (int? offset) async => await transactionController.getRideIncomeStatement(offset!),
      productView: ListView.builder(
        itemCount:  transactionController.rideIncomeStatement?.tripList?.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        itemBuilder: (context, index) {
          return  _RideStatementCard(tripDetails:  transactionController.rideIncomeStatement?.tripList?[index],);
        },
      ),
    ) : tripModel != null && tripModel.tripList != null && tripModel.tripList!.isEmpty ?
    SizedBox( height: Get.height * 0.2,child: Center(child: Text('no_transaction_found'.tr))) : SizedBox(
        height: Get.height * 0.2, child: const Center(child: CircularProgressIndicator(),
    ));
  }
}


class _DeliveryStatementPaginatedView extends StatelessWidget {
  final MyAccountController transactionController;
  final ScrollController scrollController;
  const _DeliveryStatementPaginatedView(this.transactionController, this.scrollController);

  @override
  Widget build(BuildContext context) {

    DeliveryIncomeStatementModel? deliveryStatement = transactionController.deliveryIncomeStatementModel;

    return deliveryStatement != null && deliveryStatement.transactions != null && deliveryStatement.transactions!.isNotEmpty ? PaginatedListViewWidget(
      scrollController: scrollController,
      totalSize: transactionController.deliveryIncomeStatementModel?.totalSize,
      offset: transactionController.deliveryIncomeStatementModel?.offset,
      onPaginate: (int? offset) async => await transactionController.getDeliveryIncomeStatement(offset!),
      productView: ListView.builder(
        itemCount: transactionController.deliveryIncomeStatementModel?.transactions?.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        itemBuilder: (context, index) {
          return  _DeliveryStatementCard(statement:  transactionController.deliveryIncomeStatementModel?.transactions?[index],);
        },
      ),
    ) : deliveryStatement != null && deliveryStatement.transactions != null && deliveryStatement.transactions!.isEmpty ?
    SizedBox( height: Get.height * 0.2,child: Center(child: Text('no_transaction_found'.tr))) : SizedBox(
        height: Get.height * 0.2, child: const Center(child: CircularProgressIndicator(),
    ));
  }
}




class _DeliveryStatementCard extends StatelessWidget {
  final DeliveryIncomeStatement? statement;
  const _DeliveryStatementCard({this.statement});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Get.bottomSheet(DeliveryIncomeBottomSheet(statement: statement!,));
      },
      child: Column(children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(PriceConverterHelper.convertPrice(_calculateDriverIncome(
                  statement?.originalDeliveryCharge  ?? 0, statement?.deliveryFeeComission ?? 0 , statement?.dmTips ?? 0
                )), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), textDirection: TextDirection.ltr,),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text('delivery_income'.tr, style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                )),
              ]),
            ),
            Text( DateConverterHelper.formatUtcTime(statement!.createdAt!),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            ),
          ]),
        ),

        const Divider(height: 1),
      ]),
    );
  }

  double _calculateDriverIncome(double originalDeliveryCharge, double deliveryFeeCommission, double dmTips){
    return originalDeliveryCharge + dmTips - deliveryFeeCommission;
  }
}

class _RideStatementCard extends StatelessWidget {
  final RideDetails? tripDetails;
  const _RideStatementCard({this.tripDetails});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Get.bottomSheet(RideIncomeBottomSheet(tripDetail: tripDetails!));
      },
      child: Column(children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(PriceConverterHelper.convertPrice(_calculateDriverIncome(
                  tripDetails?.paidFare ?? 0,
                  tripDetails?.adminCommission ?? 0,
                  tripDetails?.couponAmount ?? 0,
                  tripDetails?.discountAmount ?? 0,
                )), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), textDirection: TextDirection.ltr,),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text('ride_income'.tr, style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                )),
              ]),
            ),
            Text( DateConverterHelper.formatUtcTime(tripDetails!.createdAt!),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            ),
          ]),
        ),

        const Divider(height: 1),
      ]),
    );
  }

  double _calculateDriverIncome(double paidFare, double adminCommission, double coupon, double discount){
    return paidFare + coupon + discount  - adminCommission;
  }
}
