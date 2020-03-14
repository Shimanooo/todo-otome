var button = document.getElementById('button'),
  audioArr = [
    'assets/voice/fight_1.mp3',
    'assets/voice/fight_1.mp3',
    'assets/voice/fight_1.mp3',
  ];

var playAudio = function () {
  var audio = new Audio(),
    num = Math.floor(Math.random() * audioArr.length);

  if (num == audioArr.length) {
    num = audioArr.length - 1;
  }
  audio.src = audioArr[num];
  audio.play();
}

button.addEventListener('click', function () {
  playAudio();
}, false);