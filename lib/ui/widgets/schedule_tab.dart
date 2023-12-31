import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goipvc/models/myipvc/lesson.dart';
import 'package:goipvc/providers/schedule_provider.dart';
import 'package:goipvc/services/date_verification.dart';
import 'package:goipvc/ui/views/error.dart';
import 'package:goipvc/ui/views/info.dart';
import 'package:goipvc/ui/views/loading.dart';
import 'package:goipvc/ui/widgets/lesson_card.dart';

final _refreshProvider = StreamProvider<void>((ref) {
  return Stream.periodic(const Duration(seconds: 60), (count) => count);
});

class ScheduleTab<T> extends StatelessWidget {
  const ScheduleTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      AsyncValue<List<MyIPVCLesson>> schedule = ref.watch(scheduleProvider);
      ref.watch(_refreshProvider);

      if(schedule.isRefreshing){
        return const LoadingView();
      }

      return Align(
        alignment: Alignment.center,
        child: schedule.when(
            loading: () => const LoadingView(),
            error: (err, stack) => ErrorView(
              error: "$err",
              callback: () {schedule = ref.refresh(scheduleProvider);},
            ),
            data: (schedule) {
              List<MyIPVCLesson> todaySchedule = [];
              bool lessonsToday = false;

              for (var lesson in schedule) {
                if(["#ff0000", "#f4b7b7", "#f0a0a0", "#f0a0a0", "#7f5555"]
                    .contains(lesson.corValor)){
                  continue;
                }

                DateTime lessonDate = DateTime.parse(lesson.dataHoraIni);
                lessonDate =
                    DateTime(lessonDate.year, lessonDate.month, lessonDate.day);
                DateTime now = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day);

                if (lessonDate.difference(now).inDays == 0) {
                  lessonsToday = true;
                }

                if (!verifyIfLessonExpired(lesson)) {
                  todaySchedule.add(lesson);
                }
              }

              return RefreshIndicator(
                onRefresh: () async {return ref.refresh(scheduleProvider);},
                child: Builder(builder: (context) {
                  if (todaySchedule.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: lessonsToday
                            ? const InfoView(message: "Não existem mais aulas hoje")
                            : const InfoView(message: "Não existem aulas hoje")
                        )
                      ],
                    );
                  }

                  return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: todaySchedule.length,
                      itemBuilder: (context, i) {
                        return LessonCard(lesson: todaySchedule[i]);
                      }
                  );
                })
              );
            }),
      );
    });
  }
}
