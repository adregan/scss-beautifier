(function() {
  var inputTextarea = document.querySelector('.js-input-ta');
  var outputTextarea = document.querySelector('.js-output-ta');
  var submitButton = document.querySelector('.js-submit-button');

  inputTextarea.addEventListener('keydown', function(e) {
    if (e.keyCode === 9) {
      e.preventDefault();
      e.target.value = e.target.value += "  ";
    }
  });

  var scssSubmit = submitButton.addEventListener('click', function() {
    var req = new XMLHttpRequest();
    function scssLoaded(res) {
      if (req.status === 200) {
        outputTextarea.value = req.response;
      } else {
        alert('There was an issue on the server.');
      }
    }
    req.addEventListener("load", scssLoaded);
    req.open("POST", "/beautify");
    req.send(inputTextarea.value);
  });
})();
