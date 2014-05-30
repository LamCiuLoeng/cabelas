function toCancel(){
    if(confirm("Are you sure to leave this page without saving ?")){
        window.location.href = "/index";
    }else{
        return;
    }
    
}

function toSave(){
    var msg = [];
    
    $(".error").removeClass("error");

    var fields = ['shipCompany','billCompany','shipAddress','billAddress',
                  'shipCity','billCity','shipState','billState',
                  'shipCountry','billCountry','shipTel','billTel','shipEmail','billEmail',
                  'customerpo','vendorpo'];

    var allOK = true;         
    for(var i=0;i<fields.length;i++){
        var n = fields[i];
        if(!$("#"+n).val()){
            $("#"+n).addClass('error');
            allOK = false;
        }
    }
    if(!allOK){ msg.push('Please fill in the required field(s)!'); }
        
    if(msg.length > 0 ){
        var m = '<ul>';
        for(var i=0;i<msg.length;i++){ m += '<li>' + msg[i] + '</li>'; }
        m += '</ul>';        
        var html = '<div id="alert-message" title="Alert">'+ m +'</div>';
        $(html).dialog({
              modal: true,
              width: 500,
              buttons: {
                Ok: function() { $( this ).dialog( "close" ); }
              }
        });
        return;
    }else{ 
        $("form").submit();
    }
    
}


function removeItem(flag,obj){
    if(!window.confirm("Are you sure to remove this item ?")){
        return;
    }
    var params = {
        _k : flag,
        t : $.now()
    };
    $.getJSON('/ordering/ajaxRemoveItem',params,function(r){
        if(r.flag != 0 ){
            alert(r.msg);
            return;
        }else{
            alert('Remove the item successfully!');
            var t = $(obj);
            $(t.parents("tr")[0]).remove();
        }
    });
}


function searchItems(values,id,f){
    if(f === undefined ){
        f = 'a';
    }
    var r = new RegExp("^option_"+f+"_"+id,"g");
    var result = [];
    for(var i=0;i<values.length;i++){
        var t = values[i];
        if(t.key.search(r) > -1){
            result.push(t);
        }
    }
    return result;
}


function outputOptions(list,val){
    html = '';
    for(var i=0;i<list.length;i++){
        var t = list[i];
        if(t.key+'' == val + ''){
            html += '<option value="'+t.key+'" selected="selected">'+t.val+'</option>';
        }else{
            html += '<option value="'+t.key+'">'+t.val+'</option>';
        }
    }
    return html;
}

function findMatch(key,values){
    var tmp = key.replace("_as_","_at_");
    for(var i=0;i<values.length;i++){
        if( tmp == values[i].key){ return values[i]; }
    }
    return null;
}


function editItem(flag){
    var params = {
        _k : flag,
        t : $.now()
    };
    $.getJSON('/ordering/ajaxEditItem',params,function(r){
        if(r.flag != 0){
            alert(r.msg);
            return;
        }else{
            //parese the product option begin
            var html = '<tr><td style="width:200px">Qty</td><td><input type="text" class="option num required" id="item_qty" name="qty" moq="'+r.product.moq+'" roundup="'+r.product.roundup+'" onchange="adjustqty(this)" value="'+r.product.qty+'"/></td></tr>';
            for(var i=0;i<r.options.length;i++){
                var option = r.options[i];
                html += '<tr><td valign="top">' + option.name + '</td><td>';
                if(option.type == 'TEXT'){ // ONLY TEXT
                    var existing =  searchItems(r.values, option.id);
                    var css = option.css.TEXT.join(" ");      
                    if(option.multiple == 'Y'){  //multiple 
                        for(var j=0;j<existing.length;j++){  //add the previous input value
                            var e = existing[j];
                            html += '<div><input type="text" class="option '+css+'" name="'+e.key+'" value="' + e.value + '"/>';
                            if(j==0){
                                html += '&nbsp;<input type="button" class="btn" value="Add" onclick="addrow(this)"/></div>';
                            }else{
                                html += '&nbsp;<input type="button" class="btn" value="Del" onclick="delrow(this)"/></div>';
                            }
                        }
                        html += '<div class="template"><input type="text" class="option '+css+'" name="option_a_'+option.id+'_x" value=""/>';
                        html += '&nbsp;<input type="button" class="btn" value="Del" onclick="delrow(this)"/></div>';
                    }else{
                        if(existing.length > 0){
                            html += '<input type="text" class="option '+css+'" name="'+existing[0].key+'" value="'+existing[0].value+'"/>';
                        }else{
                            html += '<input type="text" class="option '+css+'" name="option_a_'+option.id+'" value=""/>';
                        }
                    }
                }else if(option.type == 'SELECT'){ // ONLY SELECT
                    var existing =  searchItems(r.values, option.id);
                    var css = option.css.SELECT.join(" ");
                    if(option.multiple == 'Y'){  //multiple
                        for(var j=0;j<existing.length;j++){  //add the previous input value
                            var e = existing[j];
                            html += '<div><select name="'+e.key+'" class="option '+css+'">';
                            html += outputOptions(option.values,e.value);
                            html += '</select>';
                            if(j==0){
                                html += '&nbsp;<input type="button" class="btn" value="Add" onclick="addrow(this)"/></div>';
                            }else{
                                html += '&nbsp;<input type="button" class="btn" value="Del" onclick="delrow(this)"/></div>';
                            }
                        }                        
                        html += '<div class="template"><select name="option_a_'+option.id+'_x" class="option '+css+'">'+outputOptions(option.values,null)+'</select>';
                        html += '&nbsp;<input type="button" class="btn" value="Del" onclick="delrow(this)"/></div>';
                    }else{
                        if(existing.length > 0){
                            html += '<select name="'+existing[0].key+'" class="option '+css+'">'+outputOptions(option.values,existing[0].value)+'</select>';
                        }else{
                            html += '<select name="option_a_'+option.id+'" class="option '+css+'">'+outputOptions(option.values,null)+'</select>';
                        }          
                    }                                   
                }
                html += '</td></tr>';
            }// FOR
                
            $("#option-tb").html(html);
            $(".num,.float","#option-tb").numeric();
            //parese the product option end
            $("#current_item").val(flag);
            $( "#option-div" ).dialog( "open" );
        }
    });
}


function savetocart(){
    var msg = checkInput();
    if(msg.length > 0){
        alert(msg.join('\n'));
        return;
    }
    var _k = $("#current_item").val();
    var qty = $("#item_qty").val();
    var params = {
        _k : _k,
        qty : qty,
        t : $.now()
    };
    
    $(".template").remove();
    $("[name^='option_']").each(function(){
        var t = $(this);
        
        if(t.prop('tagName') == 'INPUT'){
            params[t.attr('name')] = [t.val(),t.val()].join("|");
        }else if(t.prop('tagName') == 'SELECT'){
            params[t.attr('name')] = [t.val(),$(":selected",t).text()].join("|");
        }        
    });
    
    $.getJSON('/ordering/ajaxSavetoCart',params,function(r){
        if(r.flag !=0){
            alert(r.msg);
        }else{
            //window.location.reload(true);
            var html = '<ul>';
            for(var i=0;i<r.optionstext.length;i++){
                html += '<li>' + r.optionstext[i] + '</li>';
            }
            html += '</ul>';
            $("#ot_" + _k).html(html);
            $("#qty_" + _k).text(qty);
            $("#price_" + _k).html(r.price);
            $("#leadTime_" + _k).html(r.leadTime);
            $( "#option-div" ).dialog( "close" );
        }
    });
}
