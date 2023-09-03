using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class CogDisplayView extends Ui.DataField {

	// Load user settings (wheel size, number of teeth, etc...)
    var nChainRings = Application.getApp().getProperty("chainRingCount");
  	var chainRings = [Application.getApp().getProperty("chainRing1"), 
						Application.getApp().getProperty("chainRing2"),
						Application.getApp().getProperty("chainRing3")];
						  
	var wheelSet = Application.getApp().getProperty("wheelSelected");
	
	var wheelCircumference1 = ((Application.getApp().getProperty("tireWidth1")*2+622)*Math.PI) / 1000;
	var cogs1 = [Application.getApp().getProperty("cog1_1"), 
						Application.getApp().getProperty("cog1_2"), 
						Application.getApp().getProperty("cog1_3"), 
						Application.getApp().getProperty("cog1_4"), 
						Application.getApp().getProperty("cog1_5"), 
						Application.getApp().getProperty("cog1_6"), 
						Application.getApp().getProperty("cog1_7"), 
						Application.getApp().getProperty("cog1_8"), 
						Application.getApp().getProperty("cog1_9"), 
						Application.getApp().getProperty("cog1_10"), 
						Application.getApp().getProperty("cog1_11")];
						
	var wheelCircumference2 = ((Application.getApp().getProperty("tireWidth2")*2+622)*Math.PI) / 1000;
	var cogs2 = [Application.getApp().getProperty("cog2_1"), 
						Application.getApp().getProperty("cog2_2"), 
						Application.getApp().getProperty("cog2_3"), 
						Application.getApp().getProperty("cog2_4"), 
						Application.getApp().getProperty("cog2_5"), 
						Application.getApp().getProperty("cog2_6"), 
						Application.getApp().getProperty("cog2_7"), 
						Application.getApp().getProperty("cog2_8"), 
						Application.getApp().getProperty("cog2_9"), 
						Application.getApp().getProperty("cog2_10"), 
						Application.getApp().getProperty("cog2_11")];

	
	var ringRatios = new [nChainRings];	
						
						
	// Initialize variables
	var wheelRotSpeed = 0.0;  // wheel speed in rpm					
	var measuredRatio = 0.0;  // Ratio computed from cadence and speed	
	var developmentM  = 0.0;  // meters of development				
	var valid = false;
	
	hidden var ratioField = null;
	hidden var developmentField = null;

	var cogs;
	var wheelCircumference;	

    function initialize() {
    	if(wheelSet==1){
	    	cogs = cogs1;
	    	wheelCircumference = wheelCircumference1;
    	}else{
    		cogs = cogs2;
	    	wheelCircumference = wheelCircumference2;
    	}
    	
    	// Create an array of [nChainRings, 11]
    	for (var i = 0; i<nChainRings; i++){
    		ringRatios[i] = new [11];
		}
	    for (var i = 0; i<nChainRings; i++){
	    	for (var j = 0; j<11; j++){
				ringRatios[i][j] = 1.0*chainRings[i]/cogs[j];
	    	}
    	}
    	
//    	System.println(cogs);
//    	for (var i = 0; i<nChainRings; i++){
//    		System.println(chainRings[i] + ": "+ringRatios[i]);
//    	}
    	
        DataField.initialize();
        
        ratioField = createField("gearRatio",
           0, 
           FitContributor.DATA_TYPE_FLOAT,
           { :units=>"one" });
           
                   
        developmentField = createField("metersOfDevelopment",
           1, 
           FitContributor.DATA_TYPE_FLOAT, 
           { :units=>"m" });
           
        ratioField.setData(0.0);
        developmentField.setData(0.0);

    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {

    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
//        System.println("compute()");
//    	System.println("  cad="+info.currentCadence + " rpm");
//    	System.println("  spd="+info.currentSpeed * 2.2 + " mph");
    	
		if (info.currentCadence != null && info.currentSpeed != null 
			&& info.currentSpeed != 0.0 && info.currentCadence > 20  && info.currentCadence < 500)
			{
				wheelRotSpeed = info.currentSpeed / wheelCircumference;
				developmentM  = info.currentSpeed / (info.currentCadence/60.0);
				measuredRatio =  developmentM / wheelCircumference;
//				
//				System.println("  whlspd="+wheelRotSpeed + " r/s");
//    			System.println("  ratio ="+measuredRatio);
//    			System.println("  devel ="+developmentM + " m");
    			

				ratioField.setData(measuredRatio);
				developmentField.setData(developmentM);
				valid = true;
				
			} else {
				valid = false;
			}

	    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {

    	
        var bgColor = getBackgroundColor();
        var fgColor = Graphics.COLOR_WHITE;

        if (bgColor == Graphics.COLOR_WHITE) {
            fgColor = Graphics.COLOR_BLACK;
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();
        dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);
        
        var padding = 15;
		var x1 = padding;
		var w = dc.getWidth()-padding*2;
		var h  = 16;
		var small = ringRatios[0][0];
		var large = ringRatios[nChainRings-1][10];
		var range = large-small;
		var logbase = 10;
		
		// Grey background for each chainring
		for (var i = 0; i<nChainRings; i++){
		    var xl = (Math.log(ringRatios[i][0], logbase) - Math.log(small,logbase))/(Math.log(large,logbase)-Math.log(small,logbase)) * w + x1;
		    var xr = (Math.log(ringRatios[i][10], logbase) - Math.log(small,logbase))/(Math.log(large,logbase)-Math.log(small,logbase)) * w + x1;

    		var yt = padding+i*(h/nChainRings);
    		var yb = padding+(i+1)*(h/nChainRings);
    		
			dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle( xl, yt, xr-xl, yb-yt);
    	}
    	
    	
		// Red cursor for current ratio    	
    	dc.setColor(Gfx.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		
	    var x = (Math.log(measuredRatio, logbase) - Math.log(small,logbase))/(Math.log(large,logbase)-Math.log(small,logbase)) * w + x1;
		
		if ( x<padding )  { x = padding;}
		if ( x>padding+w-1 ){ x = padding+w-1; }
		dc.setPenWidth(3);
		dc.drawLine(x, padding, x, padding+h);
		dc.setPenWidth(1);

		// Black ticks for each gear combo
		dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);
		for (var i = 0; i<nChainRings; i++){
	    	for (var j = 0; j<11; j++){
	    		var r = ringRatios[i][j];
	    		
	    		var x2 = (Math.log(r, logbase) - Math.log(small,logbase))/(Math.log(large,logbase)-Math.log(small,logbase)) * w + x1;
	    			
	    		if ( x2<padding )  { x2 = padding; }
	    		if ( x2>padding+w-1 ){ x2 = padding+w-1; }
	    		dc.drawLine(x2, padding+i*(h/nChainRings), x2, padding+(i+1)*(h/nChainRings));
	    	}
    	}
    	
		if(valid){
		  dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);
		} else {
		  dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		}
		
		dc.drawText(dc.getWidth()/2d, dc.getHeight()/2, 
		   Graphics.FONT_MEDIUM, 
		   developmentM.format("%3.1f")+" m", 
		   Graphics.TEXT_JUSTIFY_CENTER);
		
		dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);
		


    }

}