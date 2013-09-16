window.onload = function() {
  function toggleSection() {
    var action = this.className == 'hidden' ? 'show' : 'hide';
    this.className = action == 'show' ? '' : 'hidden';

    var elem = this;
    while (elem = elem.nextSibling) {
        if(elem.nodeType != document.ELEMENT_NODE) continue;
        if(elem.tagName == 'H2') break;

        elem.style.display = action == 'show' ? 'block' : 'none';
    }

    return false;
  }

  // Configure all sections and hide initally
  var sections = document.getElementsByTagName('h2');
  for(var i = 0; i < sections.length; i++) {
    var handler = toggleSection.bind(sections[i]);
    sections[i].addEventListener('click', handler);
    handler();
  }
}
