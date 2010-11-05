var STATUS = {};

STATUS.Ecommerce_Sales  = (function () {
  return {
    attach: function (block) {
    	$(block + ' .content').empty();
    	$(block).removeClass("loaded");
			$.ajax({
			  url: '/ecommerce/sales',
			  dataType: 'json',
			  success: function(data) {
		    	$(block).addClass("loaded");
          $(block + ' h1').html('Sales');

				  var salesRevenue = new Array();
				  var salesNumber = new Array();
				  var salesName = new Array();
				  var salesSKU = new Array();
						
				  $.each(data, function(index, value) { 
				    salesRevenue.push(parseInt(value[0]));
				    salesNumber.push(parseInt(value[1]));
				    salesName.push(value[2]);
				    salesSKU.push(value[3]);
				  });

          var i=0;
					for (i=0;i<=10;i++) {
						$(block + ' .content').append('<div class="product ' + salesSKU[i] + '"><img src="http://sitepoint.com/images/books/covers-92x116-bg/' + salesSKU[i] + '.png" width="60" /><h2>' + salesName[i] + '</h2><h3>$' + salesRevenue[i] + ' | ' + salesNumber[i] + ' sold</h3></div>');
					}
				}
			});
		}
  }
})();

STATUS.Ecommerce_Revenue  = (function () {
  return {
    attach: function (block) {
    	$(block + ' .content').empty();
    	$(block).removeClass("loaded");
			$.ajax({
        url: '/ecommerce/revenue',
        dataType: 'json',
        success: function(data) {
          $(block).addClass("loaded");
    			$(block + ' .content').append('<h1>Revenue</h1>');
          var revenueDateList = new Array();
          var revenueValues = new Array();
        
          $.each(data, function(index, value) { 
            revenueDateList.push(value[0]);
            revenueValues.push(parseInt(value[1]));
          });

          var overview = $.plot($(block + " .content"), [collection], {
              series: {
                  lines: { show: false, lineWidth: .5 },
                  shadowSize: 0
              },
              xaxis: { mode: "time" },
              yaxis: { min: 0, autoscaleMargin: 0.1 },
              selection: { mode: "x" }
          });
        }
      });
		}
  }
})();

STATUS.PageStats  = (function () {
  return {
    attach: function (block, url, title) {
    	$(block + ' .content').empty();
			$(block + ' h1').hide();
    	$(block).removeClass("loaded");
			$.ajax({
        url: url,
        dataType: 'json',
        success: function(data) {
          $(block).addClass("loaded");
    			$(block + ' h1').html(title);
          $(block + ' h1').show();
          dataSet = []
          $.each(data, function(index, value) { 
            dataSet.push({label: value[0],  data: value[1]});
          });   
          
          $.plot($(block + ' .content'), dataSet, 
        	{
        		pie: { 
        			show: true,
              threshold: 0.1,
        			pieStrokeLineWidth: 0, 
        			pieStrokeColor: '#FFF', 
        			showLabel: false,				//use ".pieLabel div" to format looks of labels
        		},
        		legend: {
        			show: true, 
        			position: "ne", 
        			backgroundOpacity: 0
        		} 
        	});
        }
      });
		}
  }
})();