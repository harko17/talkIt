import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:talkit/developer.dart';
import 'package:talkit/feature_box.dart';
import 'package:talkit/openAI_service.dart';
import 'package:talkit/pallete.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'developer.dart';

bool render=false;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  final _speechToText = SpeechToText();

  String _lastWords = '';
  String? genImage;
  String? genText;

  final OpenAIService openAIService=OpenAIService();
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initText();
  }

  /// This has to happen only once per app
  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _initText() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _speechToText.stop();
    flutterTts.stop();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: GestureDetector(
            onTap: (){
              showAlertDialog(context);
            },
            child: Icon(Icons.info_outline)),

        title: BounceInDown(child: const Text("TalkIt")),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            ZoomIn(
              child: Stack(
                children: [

                  Center(
                    child: Container(
                      height: 120,
                      width: 120,

                      margin: const EdgeInsets.only(top:4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage("assets/images/virtualAssistant.png"))
                    ),
                  ),
                ],
              ),
            ),
            FadeInRight(
              child: Visibility(
                visible: genImage==null,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                  ),
                  child: Text(genText==null?"Good Morning, what task can I do for you?":"$genText",style: TextStyle(color: Pallete.mainFontColor,fontSize: genText==null?20:16,fontFamily: 'Cera Pro')),
                ),
              ),
            ),
            if(genImage !=null)
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                  child: Image.network('$genImage'),

              ),
            ),
            SlideInLeft(
              child: Visibility(
                visible: genText==null && genImage==null,
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text("Here are a few features",style: TextStyle(fontFamily: 'Cera Pro',fontWeight: FontWeight.bold,fontSize: 18),)
                ),
              ),
            ),
            Visibility(
              visible: genText==null && genImage==null,
              child: ZoomIn(
                child: Column(
                  children: [
                   const FeatureBox(
                     color: Pallete.firstSuggestionBoxColor,
                     headerText: "ChatGPT",
                     descriptionText: "A smarter way to stay organized "
                         "and informed with ChatGPT",
                   ),
                    const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: "Dall-E",
                      descriptionText: "Get inspired and stay creative with your personal "
                          "assistant powered by Dall-E",
                    ),
                    const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: "Smart Voice Assistant",
                      descriptionText: "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _speechToText.isListening || render,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150,vertical: 50),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(20),
                  minHeight: 15,
                  backgroundColor: Pallete.whiteColor,
                  color: Pallete.firstSuggestionBoxColor,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        child: FloatingActionButton(
          child: Icon(_speechToText.isListening? Icons.stop:Icons.mic),
          backgroundColor: Pallete.firstSuggestionBoxColor,

          onPressed: () async {
            flutterTts.stop();
            if(await _speechToText.hasPermission && _speechToText.isNotListening)
              {
                await _startListening();
              }
            else if(_speechToText.isListening)
              {
                render=true;
                final speech = await openAIService.isArtPromptAPI(_lastWords);


                if(speech.contains('https'))
                  {
                    genImage=speech;
                    genText=null;

                    setState(() {});
                  }
                else
                  {
                    genText=speech;
                    genImage=null;

                    setState(() {});
                  }

                await systemSpeak(speech);
                await _stopListening();
                render=false;

                if(genImage!=null)
                {
                  await flutterTts.stop();

                  await systemSpeak("Generating Image");
                  setState(() {
                    render=false;
                  });


                }
                print(_lastWords);
                print(speech);

                //dispose();
              }
            else
              {
                _initSpeech();
              }
          },

        ),
      ),

    );

  }
}
showAlertDialog(BuildContext context) {

  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {

    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Pallete.whiteColor,
    title: Text("Developed By:",style: TextStyle(fontSize: 20),),
    content: Text("Harsh Kotary \nEmail: harshkotary@gmail.com",style: TextStyle(fontSize: 16),),
    actions: [

    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}