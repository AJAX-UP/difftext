<#assign currentBaseUrl="${domainUrlUtil.EJS_URL_RESOURCES}/admin/textComparison"/>
    <link rel="stylesheet" type="text/css" href="${(domainUrlUtil.EJS_STATIC_RESOURCES)!}/resources/admin/css/textComparison/textComparison.css"/>
    <div class="wrapper">
        <div class="container col-sm-12">
            <div id="tableDiv" class="row">
                <div class="form-group tableDiv">
                    <section class="textSection">
                        <label for="name">原文文本</label>
                        <textarea id="teacherText" class="htmlDiv originalText"></textarea>
                    </section>
                    <section class="textSection">
                        <label for="name">学生回答</label>
                        <textarea id="studentText" class="htmlDiv studentText"></textarea>
                    </section>
                    <section class="textSection">
                        <label for="name">对比结果</label>
                        <div id="resultText" class="htmlDiv resulteText" contenteditable="true"></div>
                    </section>
                    <section style="display: none" class="textSection">
                        <label for="name">原文标识</label>
                        <div id="oldText" class="htmlDiv resulteText" contenteditable="true"></div>
                    </section>
                    <section style="display: none" class="textSection">
                        <label for="name">新文标识</label>
                        <div id="newText" class="htmlDiv resulteText" contenteditable="true"></div>
                    </section>

                    <section  class="textSection">
                        <label for="name">比对图</label>
                        <canvas   id="canvas"></canvas>
                    </section>

                    <#--<section  class="textSection">-->
                        <#--<label for="name">比对图</label>-->
                        <#--<ul id="textSectionLi" class="textSectionLi" style="width:calc(100% - 80px)">-->

                        <#--</ul>-->
                    <#--</section>-->

                    <section class="btnGropu">
                        <button type="button" onclick="balanceBtn();return false;" class="btn balanceBtn">文本对比</button>
                    </section>
                </div>
            </div>
        </div>
    </div>
    </body>
    <script>
      $(function(){
          var w=$("#teacherText").width();
          $("#canvas").attr("width",w);
      })
     function balanceBtn() {
         var teacherText=$("#teacherText").val();
         var studentText=$("#studentText").val();
         $.ajax({
             url:'${currentBaseUrl}/compariText',
             type:'POST',
             data:{
                 teacherText:teacherText,
                 studentText:studentText
             },
             success:function(data){
                 if(data!=null){
                     $("#resultText").html(data);
                     loadOldAndNew();
                 }else{
                     layer.alert("对比失败!", { offset: '300px',title:'提示' });
                 }
             },
             error:function(){
                 layer.alert("服务器异常!", { offset: '300px',title:'提示' });
             }
         });
     }
      //生成分享图
     function cavasImg(srudentArr,teacherArr){
         var canvas = document.getElementById("canvas");
         var w=$("#teacherText").width();
         var wit=parseInt(w/14);
         var h=parseInt(teacherArr.length/wit+1)*120;
         $("#canvas").attr("height",h);
         var ctx = canvas.getContext("2d");
         //生成画图的矩形
         ctx.moveTo(0,0);
         ctx.lineTo(w,0);
         ctx.lineTo(w,h);
         ctx.lineTo(0,h);
         ctx.lineTo(0,0);
         ctx.fillStyle="white";
         ctx.fill();

         //设置水印图
         var imgs = new Image();
         imgs.src = "${(domainUrlUtil.EJS_STATIC_RESOURCES)!}/resources/admin/images/shuiyin.png";
         imgs.onload = createPat;//图片加载完成再执行
         function createPat(){
             var bg = ctx.createPattern(imgs,"repeat");
             ctx.fillStyle = bg;
             var centerw=parseInt(w/2);
             var centerh=parseInt(h/2);
             ctx.fillRect(0,0,w,h);

             //绘制学生的文本
             ctx.fillStyle="white";
             ctx.lineWidth=1;
             var studentHeight=70;//绘制字体距离canvas顶部初始的高度
             for(var i=0;i<srudentArr.length;i++){
                 ctx.font="18px Courier";
                 var index=parseInt(i/wit);
                 var xindex=i%wit;
                 if(xindex==0&&i<wit-1){
                     if(srudentArr[i].color=="red"){
                         ctx.fillStyle="red";
                         ctx.fillText(srudentArr[i].text,((xindex+1)*12),100);//绘制截取部分
                     }else{
                         ctx.fillStyle="Black";
                         ctx.fillText(srudentArr[i].text,((xindex+1)*12),100);//绘制截取部分
                     }
                 }else{
                     if(srudentArr[i].color=="red"){
                         ctx.fillStyle="red";
                         ctx.fillText(srudentArr[i].text,((xindex+1)*12),(index+1)*studentHeight+30);//绘制截取部分
                     }else{
                         ctx.fillStyle="Black";
                         ctx.fillText(srudentArr[i].text,((xindex+1)*12),(index+1)*studentHeight+30);//绘制截取部分
                     }
                 }

             }
             //绘制原文本
             ctx.fillStyle="white";
             ctx.lineWidth=1;
             var initHeight=70;//绘制字体距离canvas顶部初始的高度
             for(var j=0;j<teacherArr.length;j++){
                 ctx.font="18px Courier";
                 var index=parseInt(j/wit);
                 var xindex=j%wit;
                 if(teacherArr[j].color=="blue"){
                     ctx.fillStyle="red";
                     ctx.fillText(teacherArr[j].text,((xindex+1)*12),(index+1)*initHeight);//绘制截取部分
                 }else{
                     ctx.fillStyle="Black";
                     ctx.fillText(teacherArr[j].text,((xindex+1)*12),(index+1)*initHeight);//绘制截取部分
                 }
             }
         }
     }
     //下载图片
     function saveAsLocalImage () {
         var myCanvas = document.getElementById("canvas");
         var image = myCanvas.toDataURL("image/jpeg").replace("image/jpeg", "image/octet-stream");
         window.location.href=image;
     }

     function loadOldAndNew(){
         $("#oldText").empty();
         $("#newText").empty();
         var chlidren=$("#resultText").children();
         var elements=chlidren.clone();
         var oldText=$("<div></div>");
         var newText=$("<div></div>");
         var oldIndexArray=new Array();
         var newIndexArray=new Array();
         var spanIndex=0;
         for(var i=0;i<elements.length;i++){
             var ele=elements[i];
             var tagName=ele.tagName;
             var eleHtml=$(ele).html();
             if(tagName=='DEL'){
                 oldText.append(ele);
                 var nextEle=elements[i+1];

                 if(nextEle!=null && nextEle.tagName=='INS'){
                     var eleTitle=$(ele).prop('title');
                     var nextEleTitle=$(nextEle).prop('title');
                     if(eleTitle==nextEleTitle){
                         var eleHtml=$(ele).html();
                         var nextEleHtml=$(nextEle).html();
                         var addCount=nextEleHtml.length-eleHtml.length;
                         if(addCount>0){
                             var record=new Object();
                             record.index=spanIndex;
                             record.addCount=addCount;
                             record.appendType='behind';
                             oldIndexArray.push(record);
                         }
                     }
                 }else{
                     if(eleHtml.endWith(' ')){
                         var record=new Object();
                         record.index=spanIndex;
                         record.addCount=eleHtml.length;
                         record.appendType='front';
                         newIndexArray.push(record);
                     }else{
                         var record=new Object();
                         record.index=spanIndex;
                         record.addCount=eleHtml.length;
                         record.appendType='behind';
                         newIndexArray.push(record);
                     }

                 }
             }else if(tagName=='INS'){
                 newText.append(ele);
                 if(i>0){
                     var prevEle=elements[i-1];
                     if(prevEle.tagName=='DEL'){
                         var eleTitle=$(ele).prop('title');
                         var prevEleTile=$(prevEle).prop('title');
                         if(eleTitle==prevEleTile){
                             var eleHtml=$(ele).html();
                             var prevEleHtml=$(prevEle).html();
                             var addCount=prevEleHtml.length-eleHtml.length;
                             if(addCount>0){
                                 var record=new Object();
                                 record.index=spanIndex;
                                 record.addCount=addCount;
                                 record.appendType='behind';
                                 newIndexArray.push(record);
                             }
                         }
                     }else{
                         if(eleHtml.endWith(' ')){
                             var record=new Object();
                             record.index=spanIndex;
                             record.addCount=eleHtml.length;
                             record.appendType='front';
                             oldIndexArray.push(record);
                         }else{
                             var record=new Object();
                             record.index=spanIndex;
                             record.addCount=eleHtml.length;
                             record.appendType='behind';
                             oldIndexArray.push(record);
                         }
                     }
                 }else{
                     var record=new Object();
                     record.index=spanIndex;
                     var eleHtml=$(ele).html();
                     record.addCount=eleHtml.length;
                     record.appendType='behind';
                     oldIndexArray.push(record);
                 }
             }else if(tagName=='SPAN'){
                 oldText.append('<span>'+$(ele).html()+'</span>');
                 newText.append('<span>'+$(ele).html()+'</span>');
                 spanIndex++;
             }
         }
         $("#oldText").append(oldText.html());
         $("#newText").append(newText.html());
         console.info(oldIndexArray);
         console.info(newIndexArray);
         var oldSpans=$("#oldText").find("span");
         //循环当前分离出的原文DIV的子元素
         for(var i=0;i<oldSpans.length;i++){
             //循环记录下来的加空格的record数组
             for(var k=0;k<oldIndexArray.length;k++){
                 //获取当前record对象
                 var oldIndexArrayElement=oldIndexArray[k];
                 //获取要加空格的span的index
                 var oldIndexArrayElementIndex=oldIndexArrayElement.index;
                 //获取要加的空格的数量
                 var oldIndexArrayElementAddCount=oldIndexArrayElement.addCount;
                 //判断是否是同一个span
                 if(i==oldIndexArrayElementIndex){
                     //获取span的html
                     var oldSpanHtml=$(oldSpans[i]).html();
                     if(oldIndexArrayElement.appendType='front'){
                         var spaceStr='';
                         for(var j=0;j<oldIndexArrayElementAddCount;j++){
                             spaceStr+=' ';
                         }
                         oldSpanHtml = spaceStr+oldSpanHtml;
                         $(oldSpans[i]).html(oldSpanHtml);
                     }else{
                         //查看span是否包含' '
                         var spaceIdx=oldSpanHtml.indexOf(' ');
                         if(spaceIdx!=-1){
                             var spaceStr='';
                             for(var j=0;j<oldIndexArrayElementAddCount;j++){
                                 spaceStr+=' ';
                             }
                             oldSpanHtml = oldSpanHtml.slice( 0 , spaceIdx ) + spaceStr + oldSpanHtml.slice( spaceIdx );
                             $(oldSpans[i]).html(oldSpanHtml);
                         }else{
                             var spaceStr='';
                             for(var j=0;j<oldIndexArrayElementAddCount;j++){
                                 spaceStr+=' ';
                             }
                             oldSpanHtml = oldSpanHtml+spaceStr;
                             $(oldSpans[i]).html(oldSpanHtml);
                         }
                     }
                 }
             }
         }

         var newSpans=$("#newText").find("span");
         //循环当前分离出的原文DIV的子元素
         for(var i=0;i<newSpans.length;i++){
             //循环记录下来的加空格的record数组
             for(var k=0;k<newIndexArray.length;k++){
                 //获取当前record对象
                 var newIndexArrayElement=newIndexArray[k];
                 //获取要加空格的span的index
                 var newIndexArrayElementIndex=newIndexArrayElement.index;
                 //获取要加的空格的数量
                 var newIndexArrayElementAddCount=newIndexArrayElement.addCount;
                 //判断是否是同一个span
                 if(i==newIndexArrayElementIndex){
                     //获取span的html
                     var newSpanHtml=$(newSpans[i]).html();
                     if(newIndexArrayElement.appendType='front'){
                         var spaceStr='';
                         for(var j=0;j<newIndexArrayElementAddCount;j++){
                             spaceStr+=' ';
                         }
                         newSpanHtml = spaceStr+newSpanHtml;
                         $(newSpans[i]).html(newSpanHtml);
                     }else{
                         //查看span是否包含' '
                         var spaceIdx=newSpanHtml.indexOf(' ');
                         if(spaceIdx!=-1){
                             var spaceStr='';
                             for(var j=0;j<newIndexArrayElementAddCount;j++){
                                 spaceStr+=' ';
                             }
                             newSpanHtml = newSpanHtml.slice( 0 , spaceIdx ) + spaceStr + newSpanHtml.slice( spaceIdx );
                             $(newSpans[i]).html(newSpanHtml);
                         }else{
                             var spaceStr='';
                             for(var j=0;j<newIndexArrayElementAddCount;j++){
                                 spaceStr+=' ';
                             }
                             newSpanHtml = newSpanHtml+spaceStr;
                             $(newSpans[i]).html(newSpanHtml);
                         }
                     }
                 }
             }
         }

         //获取子元素
         var oldTextChildren=$("#oldText").children();
         //保存打印元素得数组
         var oldTextElementArray=null;
         if(oldTextChildren){
             oldTextElementArray=new Array();
             for(var i=0;i<oldTextChildren.length;i++){
                 var cuurentEle=oldTextChildren[i];
                 if(cuurentEle.tagName=='DEL'){
                     var eleHtml=$(cuurentEle).html();
                     for(var k=0;k<eleHtml.length;k++){
                         var currentChar=eleHtml.charAt(k);
                         var eleObj=new Object();
                         eleObj.text=currentChar;
                         eleObj.color='blue';
                         oldTextElementArray.push(eleObj);
                     }
                 }else{
                     var eleHtml=$(cuurentEle).html();
                     for(var k=0;k<eleHtml.length;k++){
                         var currentChar=eleHtml.charAt(k);
                         var eleObj=new Object();
                         eleObj.text=currentChar;
                         eleObj.color='black';
                         oldTextElementArray.push(eleObj);
                     }
                 }
             }
         }

         //获取子元素
         var newTextChildren=$("#newText").children();
         //保存打印元素得数组
         var newTextElementArray=null;
         if(newTextChildren){
             newTextElementArray=new Array();
             for(var i=0;i<newTextChildren.length;i++){
                 var cuurentEle=newTextChildren[i];
                 if(cuurentEle.tagName=='INS'){
                     var eleHtml=$(cuurentEle).html();
                     for(var k=0;k<eleHtml.length;k++){
                         var currentChar=eleHtml.charAt(k);
                         var eleObj=new Object();
                         eleObj.text=currentChar;
                         eleObj.color='red';
                         newTextElementArray.push(eleObj);
                     }
                 }else{
                     var eleHtml=$(cuurentEle).html();
                     for(var k=0;k<eleHtml.length;k++){
                         var currentChar=eleHtml.charAt(k);
                         var eleObj=new Object();
                         eleObj.text=currentChar;
                         eleObj.color='black';
                         newTextElementArray.push(eleObj);
                     }
                 }
             }
         }
         //画图
         cavasImg(newTextElementArray,oldTextElementArray);
         //生成html
         //cavasHtml(newTextElementArray,oldTextElementArray);
     }


     Array.prototype.clone = function(){
         var a=[];
         for(var i=0,l=this.length;i<l;i++) {
             a.push(this[i]);
         }
         return a;
     }
     String.prototype.endWith=function(str){
         if(str==null||str==""||this.length==0||str.length>this.length)
             return false;
         if(this.substring(this.length-str.length)==str)
             return true;
         else
             return false;
         return true;
     }
      function cavasHtml(srudentArr,teacherArr){
          var htmlStr="";
          var len=teacherArr.length;
          for(var i=0;i<len/100;i++){
              var spanHtml="";
              for(var j=i*100;j<((i+1)*100);j++){
                  if(len>j){
                      if(teacherArr[j].color=='blue'){
                          spanHtml=spanHtml+"<p  style='color:red;font-family: Courier;'>"+teacherArr[j].text+"</p>"
                      }else{
                          if(teacherArr[j].text==" "){
                              spanHtml=spanHtml+"<p style='font-family: Courier;' >&nbsp;</p>";
                          }else{
                              spanHtml=spanHtml+"<p style='font-family: Courier;' >"+teacherArr[j].text+"</p>";
                          }

                      }
                  }
              }
              var spanHtml2="";
              for(var m=i*100;m<((i+1)*100);m++){
                  if(len>m){
                      if(srudentArr[m].color=='red'){
                          spanHtml2=spanHtml2+"<p style='color:red;font-family: Courier;'>"+srudentArr[m].text+"</p>"
                      }else{
                          if(srudentArr[m].text==" "){
                              spanHtml2=spanHtml2+"<p style='font-family: Courier;' >&nbsp;</p>";
                          }else{
                              spanHtml2=spanHtml2+"<p style='font-family: Courier;' >"+srudentArr[m].text+"</p>";
                          }
                      }
                  }
              }
              htmlStr=htmlStr+"<li style='width:100%;display:flex;flex-wrap:wrap;align-items: center;'>"+spanHtml+"</li>";
              htmlStr=htmlStr+"<li style='width:100%;display:flex;flex-wrap:wrap;align-items: center;'>"+spanHtml2+"</li>";
          }
          $("#textSectionLi").append(htmlStr);

      }
    </script>
