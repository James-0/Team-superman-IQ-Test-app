import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:example/core/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/*import 'core/quiz.dart';*/

class QuizPage extends StatefulWidget {
  final String category;
  final bool timed;

  const QuizPage({Key key, this.category, this.timed}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  double percentToRangeOPoint1To1 = 0;

  String tag;

  Future<Quiz> loadQuestions() async {
    String data = await rootBundle.loadString('assets/question.json');
    var jsonResult = json.decode(data);
    int jsonIndex = Random().nextInt(3);
    switch (jsonIndex) {
      case 0:
        tag = "Cognitive";
        break;
      case 1:
        tag = "Arithmetics";
        break;
      case 2:
        tag = "General";
        break;
      case 3:
        tag = "Geography";
        break;
    }
    var quiz = Quiz.fromJson(jsonResult[jsonIndex]);
    return quiz;
  }

  @override
  void initState() {
    super.initState();
    prepareUI();
    if (widget.timed) {
      initTimer();
    }
  }

  Quiz quiz;
  List<Widget> questions = [];

  Timer timer;

  void initTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        duration--;
        if (duration < 6) {
          durationColor = Colors.red;
        }
        if (duration == 0) {
          hasSelectedOption = true;
          questionTimedOut = true;
          prepareUI(true);
          timer.cancel();
        }
      });
    });
  }

  int duration = 4;
  bool questionTimedOut = false;
  Color durationColor = Colors.black;
  List<int> prevIndices = [];
  String currentQuestion;
  String questionCategory;

  int index;

  void prepareUI([usePrevIndices = false]) async {
    if(!usePrevIndices){
      quiz = await loadQuestions();
    }
    if (!usePrevIndices) {
      setState(() {
        duration = 30;
      });
    }
    setState(() {
      questions = [];
      quiz.questions.forEach(
            (element) {
          questions.add(
            QuestionItem(
              hasSelectedOption: questionTimedOut,
              question: element,
              key: UniqueKey(),
              onBuild: (previousIndices) {
                prevIndices = previousIndices;
              },
              previousIndices: usePrevIndices ? prevIndices : null,
              timedOut: questionTimedOut,
              onOptionSelected: (bool wasCorrect) {
                setState(() {
                  hasSelectedOption = true;
                  if (widget.timed) {
                    timer.cancel();
                  }
                });
                if (wasCorrect) {
                  setState(() {
                    mark++;
                  });
                }
              },
            ),
          );
        },
      );
    });
    if(!usePrevIndices){
      index = Random().nextInt(questions.length - 1);
      while(indices.contains(index)){
        index = Random().nextInt(questions.length - 1);
      }
      indices.add(index);
    }
  }

  List<int> indices = [];

  int questionIndex = 0;
  int mark = 0;
  bool hasSelectedOption = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xffF2F2F2),
          child: questions.isNotEmpty ? Column(
            children: <Widget>[
              SizedBox(height: 10),
              //Assessment and Eng
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Text(
                      "IQ Assessment:",
                      style: GoogleFonts.poppins(),
                    ),
                    SizedBox(width: 5),
                    Text(
                      tag,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Container(
                      child: Text(
                        "End",
                        style: GoogleFonts.poppins(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xffFCC8C8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3),
              LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AnimationController(vsync: this).drive(
                  Tween(
                    begin: Color(0xff90BA7C),
                    end: Color(0xff90BA7C),
                  ),
                ),
                value: percentToRangeOPoint1To1,
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  width: double.maxFinite,
                  padding: EdgeInsets.all(20),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      //Timer and approx
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xff525252),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            width: 45,
                            height: 50,
                            padding: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "${widget.timed ? duration : "X"}",
                                style: GoogleFonts.oswald(
                                  fontWeight: FontWeight.w600,
                                  color: durationColor,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Approximately ${20 - questionIndex - 1} Questions Remaining",
                            style: GoogleFonts.poppins(),
                          )
                        ],
                      ),
                      SizedBox(height: 20),

                      //The Question
                      questions[index],

                      //The button
                      hasSelectedOption
                          ? Align(
                        alignment: Alignment.centerRight,
                        child: RaisedButton(
                          onPressed: () {

                            //If it is not the last question, proceed to the next one
                            if (questionIndex != 19) {
                              questionTimedOut = false;
                              durationColor = Colors.black;
                              prepareUI();
                              if (widget.timed) {
                                timer.cancel();
                                initTimer();
                              }
                              setState(
                                    () {
                                  hasSelectedOption = false;
                                  questionIndex++;
                                  int questionNumber = questionIndex;
                                  double questionPercent = (100 * questionNumber) / 20;
                                  percentToRangeOPoint1To1 =
                                      questionPercent / 100;
                                },
                              );
                            }
                            //Else submit the mark and the number of questions to dollyp
                          },
                          color: Color(0xff5982FE),
                          child: Text(
                            "${questionIndex == 19 ? "Submit" : "Next Question"}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      )
                          : SizedBox()
                    ],
                  ),
                ),
              ),
            ],
          ) : Center(child: CircularProgressIndicator(),),
        ),
      ),
    );
  }
}

class QuestionItem extends StatefulWidget {
  final Question question;
  final bool timedOut;
  final bool hasSelectedOption;
  final List<int> previousIndices;
  final Function(bool correctAnswerSelected) onOptionSelected;
  final Function(List<int> previousIndices) onBuild;

  const QuestionItem({
    Key key,
    this.question,
    this.onOptionSelected,
    this.timedOut = false,
    this.hasSelectedOption,
    this.onBuild,
    this.previousIndices,
  }) : super(key: key);

  @override
  _QuestionItemState createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  List<int> indices = [];

  @override
  void initState() {
    print(widget.timedOut);
    super.initState();
    if (widget.previousIndices != null) {
      indices = widget.previousIndices;
    } else {
      for (int i = 0; i < widget.question.incorrectAnswer.length + 1; i++) {
        indices.add(i);
      }
      indices.shuffle();
      widget.onBuild(indices);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(widget.timedOut);
  }

  @override
  void didUpdateWidget(QuestionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(widget.timedOut);
  }

  bool wrongAnswerSelected = false;

  bool isClickable = true;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isClickable || widget.hasSelectedOption,
      child: Column(
        children: <Widget>[
          Text(
            widget.question.question,
            style: GoogleFonts.poppins(
              fontSize: 18.5,
              color: Color(0xff525252),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 32),
          Column(
            children: List.generate(
              widget.question.incorrectAnswer.length + 1,
                  (index) {
                if (indices[index] == widget.question.incorrectAnswer.length) {
                  return QuestionOption(
                    isAnswer: true,
                    onTap: isClickable
                        ? (_) {
                      setState(() {
                        isClickable = false;
                        widget.onOptionSelected(true);
                      });
                    }
                        : (_) {},
                    timedOut: widget.timedOut,
                    wrongAnswerSelected: wrongAnswerSelected,
                    text: widget.question.correctAnswer,
                  );
                }
                return QuestionOption(
                  isAnswer: false,
                  onTap: isClickable
                      ? (_) {
                    setState(() {
                      isClickable = false;
                      widget.onOptionSelected(false);
                      wrongAnswerSelected = true;
                    });
                  }
                      : (_) {},
                  timedOut: false,
                  wrongAnswerSelected: true,
                  text: widget.question.incorrectAnswer[indices[index]],
                );
              },
            ),
          ),
          widget.question.explanation.isNotEmpty &&
              (!isClickable || widget.hasSelectedOption)
              ? Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Explanation",
                  style: GoogleFonts.poppins(
                    color: Color(0xff525252),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.all(17),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xff7CBE82),
                    width: 1.7,
                  ),
                  color: Color(0xff7CBE82),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.question.explanation,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          )
              : SizedBox(),
        ],
      ),
    );
  }
}

class QuestionOption extends StatefulWidget {
  final bool isAnswer;
  final String text;
  final bool wrongAnswerSelected;
  final bool timedOut;
  final Function(bool isAnswer) onTap;

  const QuestionOption({
    Key key,
    this.isAnswer = false,
    this.text,
    this.onTap,
    this.wrongAnswerSelected,
    this.timedOut,
  }) : super(key: key);

  @override
  _QuestionOptionState createState() => _QuestionOptionState();
}

class _QuestionOptionState extends State<QuestionOption> {
  Color backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.isAnswer);
        setState(() {
          if (!widget.isAnswer) {
            backgroundColor = Color(0xffCD2121);
          } else {
            backgroundColor = Color(0xff7CBE82);
          }
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(17),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isAnswer && widget.wrongAnswerSelected
                    ? Color(0xff7CBE82)
                    : Color(0xffC7C7C7),
                width: 1.7,
              ),
              color: widget.timedOut ? Color(0xffCD2121) : backgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              widget.text,
              style: GoogleFonts.poppins(
                color: widget.timedOut
                    ? Colors.white
                    : backgroundColor == Colors.transparent
                    ? Color(0xff525252)
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}