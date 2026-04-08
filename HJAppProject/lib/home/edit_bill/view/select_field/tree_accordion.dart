import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/home/edit_bill/models/edit_select_item.dart';

class TreeAccordion<T extends BaseTreeSelectItem<T>> extends StatefulWidget {
  TreeAccordion({super.key, this.children});

  List<BaseTreeSelectItem<T>>? children = [];

  @override
  State<TreeAccordion> createState() => _TreeAccordionState<T>();
}

class _TreeAccordionState<T extends BaseTreeSelectItem<T>>
    extends State<TreeAccordion<T>> {
  @override
  Widget build(BuildContext context) {
    return Accordion(
        disableScrolling: true,
        paddingListTop: 0,
        paddingListBottom: 0,
        maxOpenSections: 1,
        headerBackgroundColorOpened: Colors.black54,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        children: widget.children != null
            ? widget.children!.map((ele) {
                return AccordionSection(
                  // isOpen: true,
                  leftIcon:
                      const Icon(Icons.category_outlined, color: Colors.white),
                  header: Text(ele.title,
                      style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  content: Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: true, signed: true), // 允许小数点的数字键盘
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,5}')), // 允许数字和最多两位小数
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '金额 - ${ele.title}',
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(12, 11, 32, 8),
                          ),
                        ),
                      ),
                      TreeAccordion(
                        children: ele.children,
                      ),
                    ],
                  ),
                );
              }).toList()
            : []);
  }
}

class MyNestedAccordion extends StatelessWidget {
  MyNestedAccordion({super.key, required this.sections});
  List<AccordionSection> sections;

  @override
  Widget build(context) //
  {
    return Accordion(
        paddingListTop: 0,
        paddingListBottom: 0,
        maxOpenSections: 1,
        headerBackgroundColorOpened: Colors.black54,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        children: sections);
  }
}
