$(document).ready(function(){
    $(".menu-tab li:not(.highlight)").each(function(){
        var orginImg = $(this).css("background-image");
        var replaceImg = "url(/images/images/main_05.jpg)"
        $(this).hover(
            function(){$(this).css("background-image",replaceImg);},
            function(){$(this).css("background-image",orginImg);}
        );
    });
    $("#function-menu a img").each(function(){
        var orginImg = $(this).attr("src");
        var replaceImg = orginImg.replace("_g.jpg",".jpg");
        $(this).hover(
            function(){$(this).attr("src",replaceImg);},
            function(){$(this).attr("src",orginImg);}
        );
    });
    $('.btn').hover(
        function () {$(this).addClass("btnhov");},
        function () {$(this).removeClass("btnhov");}
    );
    $('.sorter').click(function () {
        var klass = $(this).attr('class');
        var asc = klass.indexOf('sorter_asc')>=0 ? 'desc' : 'asc';
        $('#order_by').val(asc+'-'+$(this).attr('name'))
        toSearch();
    })
    //initDate();
    $(":file").each(function(){$(this).addClass('inputFile')})
    $(":text").each(function(){$(this).addClass('inputText')})
    $(":button").each(function(){$(this).addClass('inputButton')})
    $(":submit").each(function(){$(this).addClass('inputSubmit')})
    $(":checkbox").each(function(){$(this).addClass('inputCheckbox')})
    $(":radio").each(function(){$(this).addClass('inputRadio')})
});
function historyGo(){
    history.forward(1);
}
function historyBack(){
    history.back(-1);
}
function resetForm(){
    $('form')[0].reset();
}
var initSort = function(obj, asc){
    if(asc=='desc'){
        $(obj).removeClass('sorter')
        $(obj).removeClass('sorter_asc')
        $(obj).addClass('sorter_desc')
    }else{
        $(obj).removeClass('sorter')
        $(obj).removeClass('sorter_desc')
        $(obj).addClass('sorter_asc')
    }
}
String.prototype.getQuery = function(name) {
    var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
    var r = this.substr(this.indexOf("\?")+1).match(reg);
    if (r!=null) return unescape(r[2]); return null;
}
var disableBtn = function(obj, bool){
    if(!(obj instanceof Array)) obj = [obj]
    for(var i=0;i<obj.length;i++){
        var jq = $(obj[i]);
        if(bool){jq.attr('disabled', true);jq.addClass("btndisable");}
        else{jq.attr('disabled', false);jq.removeClass("btndisable");}
    }
}
var initDate = function(){
    var dateFormat = 'yy-mm-dd';
    $('.datePicker').datepicker({
        dateFormat: dateFormat,
        changeYear: true,
        changeMonth: true,
        showOn: 'both',
        buttonImage: '../images/calendar.gif',
        buttonImageOnly: true
    });
}
var initDateNoImg = function(){
    var dateFormat = 'yy-mm-dd';
    $('.datePicker').datepicker({
        dateFormat: dateFormat,
        changeYear: true,
        changeMonth: true
    });
}
var toggleIcon = function(obj){
    if($(obj).parent().attr('class')=='toggle1'){
        $(obj).parent().next().slideUp();
        $(obj).parent().attr('class', 'toggle2')
    }else{
        $(obj).parent().next().slideDown();
        $(obj).parent().attr('class', 'toggle1')
    }
}
var selectAll = function(obj){
    $(obj).attr("checked") ? $("tbody :checkbox").attr("checked","checked") : $("tbody :checkbox").removeAttr("checked");
}
var getCboxArr = function(){
    var str = []
    $(".cboxClass").each(function(i, obj){
        var jq=$(obj)
        if(jq.attr('checked'))
            str.push(jq.val())
    })
    return str
}
var getCboxStr = function(){
    return getCboxArr().join(',')
}
var validateCbox = function(){
    if(getCboxArr().length==0){
        showError('Please select at least one checkbox!');return false;
    }else return true;
}
var showError = function(msg){
    //if(msg instanceof Array) msg=msg.join('<br/>');
    //$.modaldialog.error(msg);
    $.prompt(msg,{
        opacity: 0.6,
        prefix:'cleanred'
    });
}
var showMsg = function(msg){
    //if(msg instanceof Array) msg=msg.join('<br/>');
    //$.growlUI('Success','  ');
    //$.modaldialog.success(msg);
    //$.prompt(msg,{opacity: 0.6,prefix:'cleanblue'});
    $.prompt(msg,{
        opacity: 0.6,
        prefix:'cleanblue'
    });
}
var showWaiting = function(){$.blockUI({message: '<img src="../images/busy.gif" /> loading...',css:{width:'150px',padding:'5px 0'}})}
var closeBlock = function(){$.unblockUI()};
var maxSq = function(pa){
	$(pa).each(function(){
		var q;
		var width = $(this).width();
		var height = $(this).height();
		if(width > 200){
			q = width/200;
			$(this).width(width*100/width);
			$(this).height(height*100/width);
			
		}
		$(this).css({"float":"left","margin":"5px"})
		
	})

}