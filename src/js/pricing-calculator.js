(function() {
  function setupSlider() {
    var $window = $(window),
        $slider = $('.slider'),
        $track = $('.track'),
        $trackFill = $('.track-fill'),
        $knob = $('.knob'),
        $dollarValue = $('.price .value .dollar-value'),
        $price = $('.price.dollar.value'),
        $contactUs = $('.contact-us'),
        $multiplier = $('.multiplier .value');


    var ONE_BILLION = 1000000000;
    var ONE_MILLION = 1000000;
    var ONE_THOUSAND = 1000;

    var FREE_REQUESTS = 100 * ONE_THOUSAND;
    var SLIDER_MAX = ONE_BILLION;
    var SLIDER_MIN = 75 * ONE_THOUSAND;

    var TIERS = [{
      "name": "Free",
      "included": 100000,
      "basePrice": 0,
      "mmPrice": null
    }, {
      "name": "Small",
      "included": 1000000,
      "basePrice": 2000,
      "mmPrice": 2000
    }, {
      "name": "Medium",
      "included": 5000000,
      "basePrice": 10000,
      "mmPrice": 1000
    }, {
      "name": "Large",
      "included": 20000000,
      "basePrice": 25000,
      "mmPrice": 400
    }, {
      "name": "XL",
      "included": 50000000,
      "basePrice": 37000,
      "mmPrice": 200
    }, {
      "name": "XXL",
      "included": 100000000,
      "basePrice": 47000,
      "mmPrice": 100
    }];

    var SHORT_NAMES = {
      "XL": "XL",
      "XXL": "2XL"
    };

    var domain = [SLIDER_MIN, SLIDER_MAX];

    var requests = 0;

    buildTierRows();
    adjustKnob(0);

    $knob.on('touchstart', function(e) {
      $window.on('touchmove', drag);
      $window.on('touchend', function() {
        $window.off('touchmove', drag);
      });
      return false;
    });

    $knob.on('mousedown', function(e) {
      $window.on('mousemove', drag);
      $window.on('mouseup', function() {
        $window.off('mousemove', drag);
      });

      return false;
    });

    $window.on('keydown', function(event) {
      var offset = $knob.position().left;

      switch (event.keyCode) {
        case 37:
          offset--;
          break;
        case 39:
          offset++;
          break;
      }

      adjustKnob(offset);
    });


    function adjustKnob(offset) {
      var width = $track.width();

      if (offset < 0) { offset = 0; }
      if (offset > width) { offset = width; }

      $knob.css('left', offset);
      $trackFill.css('width', offset);


      var requests = snap(scale(offset), 100);
      $('.total-requests .value').text(format(requests));
      $dollarValue.text(price(requests));

      var tier = bestTier(requests);
      $('.tiers tr').removeClass('is-current');
      $('.tiers .'+tier.name.toLowerCase()).addClass('is-current');

    }

    function drag(event) {
      event.preventDefault();

      // Detect if touchmove or mousemove
      var x = event.originalEvent.touches ? event.originalEvent.touches[0].pageX : event.pageX;

      var offset = x - $track.offset().left;

      adjustKnob(offset);
    }

    function inverse(value) {
      var minp = 0;
      var maxp = $track.width();

      var minv = Math.log(SLIDER_MIN);
      var maxv = Math.log(SLIDER_MAX);
      return (Math.log(value)-minv) / scale + minp;
    }

    function scale(position) {
      var minp = 0;
      var maxp = $track.width();

      var minv = Math.log(SLIDER_MIN);
      var maxv = Math.log(SLIDER_MAX);

      // calculate adjustment factor
      var ratio = (maxv-minv) / (maxp-minp);

      return Math.exp(minv + ratio*(position-minp));
    }

    function snap(value, multiple) {
      var multiplier = Math.round(value / multiple);
      return multiplier * multiple;
    }

    function format(value) {
      var precision = 0;
      var output;

      if (value >= ONE_BILLION) {
        output = [value / ONE_BILLION, " Billion"];
        precision = 1;
      } else if (value >= ONE_MILLION) {
        output = [value / ONE_MILLION, " Million"];
      } else if (value >= ONE_THOUSAND) {
        output = [value / ONE_THOUSAND, ",000"];
      } else {
        output = [value, ""];
      }

      return floorWithPrecision(output[0], precision) + output[1];
    }

    function buildTierRows() {
      var $template = $('.tiers tbody tr');
      $template.remove();

      TIERS.forEach(function(tier) {
        buildTierRow($template, tier);
      });
    }

    function buildTierRow($template, tier) {
      var $row = $template.clone();

      var price = tier.basePrice;

      if (price) {
        price = "$" + tier.basePrice / 100;
      } else {
        price = "Free";
      }

      $row.find('.name').text(shortName(tier.name));
      $row.find('.price').text(price);
      $row.find('.requests').text(format(tier.included));

      if (tier.mmPrice) {
        $row.find('.additional-price').text("$" + (tier.mmPrice / 100));
      } else {
        $row.find('.additional').text("");
      }
      $row.addClass(tier.name.toLowerCase());

      $('.tiers table tbody').append($row);
    }

    function floorWithPrecision(value, precision) {
      return Math.round(value * Math.pow(10, precision)) / Math.pow(10, precision);
    }

    function bestTier(requests) {
      if (requests <= FREE_REQUESTS) {
        return TIERS[0];
      }

      var reversedTiers = TIERS.slice();
      reversedTiers.shift();
      reversedTiers.reverse();

      var tier = findInArray(reversedTiers, function(i) {
        return i.included <= requests;
      });

      return tier || TIERS[1];
    }

    function price(requests) {
      if (requests <= FREE_REQUESTS) {
        return 0;
      }

      var tier = bestTier(requests);
      if (!tier) { return 0; }

      var additionalRequests = Math.ceil(requests / 1000000) * 1000000 - tier.included;
      additionalRequests = Math.max(0, additionalRequests);

      var additionalPrice = additionalRequests / 1000000 * tier.mmPrice;
      return (tier.basePrice + additionalPrice) / 100;
    }

    function findInArray(array, callback) {
      for (var i = 0; i < array.length; i++) {
        if (callback(array[i])) {
          return array[i];
        }
      }
    }

    function shortName(longName) {
      if (SHORT_NAMES[longName]) {
        return SHORT_NAMES[longName];
      }

      var names = longName.split(' ');

      names = names.map(function(name) {
        if (name.charAt(1) === 'x') {
          return 'X';
        }

        return name.charAt(0);
      });

      return names.join('');
    }
  }

  $(setupSlider);
})();

