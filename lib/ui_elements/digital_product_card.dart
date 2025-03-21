import 'package:ecom_flutter/custom/box_decorations.dart';
import 'package:ecom_flutter/helpers/system_config.dart';
import 'package:ecom_flutter/my_theme.dart';
import 'package:ecom_flutter/screens/digital_product/digital_product_details.dart';
import 'package:flutter/material.dart';
import 'package:ecom_flutter/screens/product_details.dart';
import 'package:ecom_flutter/app_config.dart';
class DigitalProductCard extends StatefulWidget {

  int? id;
  String? image;
  String? name;
  String? main_price;
  String? stroked_price;
  bool? has_discount;
  var discount;

  DigitalProductCard({Key? key,this.id, this.image, this.name, this.main_price,this.stroked_price,this.has_discount,this.discount}) : super(key: key);

  @override
  _DigitalProductCardState createState() => _DigitalProductCardState();
}

class _DigitalProductCardState extends State<DigitalProductCard> {
  @override
  Widget build(BuildContext context) {
    print((MediaQuery.of(context).size.width - 48 ) / 2);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return DigitalProductDetails(id: widget.id,);
        }));
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
        ),
        child: Stack(
          children: [
            Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                        width: double.infinity,
                        child: ClipRRect(
                          clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(6), bottom: Radius.zero),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder.png',
                              image:  widget.image!,
                              fit: BoxFit.cover,
                            ))),
                  ),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            widget.name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        widget.has_discount! ? Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            SystemConfig.systemCurrency!.code!=null?
                            widget.stroked_price!.replaceAll(SystemConfig.systemCurrency!.code!, SystemConfig.systemCurrency!.symbol!)
                                :widget.stroked_price!,

                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                decoration:TextDecoration.lineThrough,
                                color: MyTheme.medium_grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          ),
                        ):Container(height: 8.0,),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            SystemConfig.systemCurrency!.code!=null?
                            widget.main_price!.replaceAll(SystemConfig.systemCurrency!.code!, SystemConfig.systemCurrency!.symbol!)
                                :widget.main_price!,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),

            Visibility(
              visible: widget.has_discount!,
              child: Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffe62e04),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(6.0),
                        bottomLeft: Radius.circular(6.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x14000000),
                          offset: Offset(-1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.discount??"",
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w700,
                        height: 1.8,
                      ),
                      textHeightBehavior:
                      TextHeightBehavior(applyHeightToFirstAscent: false),
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
