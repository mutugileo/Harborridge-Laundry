import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/core/widgets/app_pagination_bar.dart';

void main() {
  group('AppPaginationBar (Max 6 per page)', () {
    test(
      'paginate slices items into pages of max 6 and clamps out-of-range pages',
      () {
        final items = List.generate(15, (i) => 'Item ${i + 1}');

        expect(AppPaginationBar.totalPagesFor(15, pageSize: 6), 3);
        expect(AppPaginationBar.paginate(items, 0, pageSize: 6), [
          'Item 1',
          'Item 2',
          'Item 3',
          'Item 4',
          'Item 5',
          'Item 6',
        ]);
        expect(AppPaginationBar.paginate(items, 1, pageSize: 6), [
          'Item 7',
          'Item 8',
          'Item 9',
          'Item 10',
          'Item 11',
          'Item 12',
        ]);
        expect(AppPaginationBar.paginate(items, 2, pageSize: 6), [
          'Item 13',
          'Item 14',
          'Item 15',
        ]);
        // Out-of-range page clamps safely to last page
        expect(AppPaginationBar.paginate(items, 99, pageSize: 6), [
          'Item 13',
          'Item 14',
          'Item 15',
        ]);
        expect(AppPaginationBar.paginate(<String>[], 0, pageSize: 6), isEmpty);
      },
    );

    testWidgets(
      'AppPaginationBar renders page controls and fires onPageChanged',
      (tester) async {
        int? selectedPage;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppPaginationBar(
                currentPage: 0,
                totalItems: 14,
                pageSize: 6,
                onPageChanged: (page) => selectedPage = page,
              ),
            ),
          ),
        );

        expect(find.text('Showing 1–6 of 14'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);

        await tester.tap(find.text('2'));
        await tester.pump();
        expect(selectedPage, 1);

        await tester.tap(find.byTooltip('Next page'));
        await tester.pump();
        expect(selectedPage, 1);
      },
    );
  });
}
