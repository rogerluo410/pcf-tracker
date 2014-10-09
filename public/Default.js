var grid;
var win;
var updatewin;
var repowin;
var baseoswin;
var updatebaseoswin;
var uploadwin;
var utwin;
var form;
var utform;
var updateform;
var repoform;
var baseosform;
var updatebaseform;
var uploadform;
var searchWin;
var searchForm;
var scotzillaWin;
var scotzillaForm;
var fatherid;
var childid;
var node_type;
var repo_data;
var father_data;
var deletewin;
var product_value ;
var selectedNodeId;

$(function () {
   InitLeftMenu();
   InitTreeData();
   $('body').layout();
   $.ajax( {                                                 
      url: '/products/1/get_latest_product',                               
      type:'get',                                                                   
      success:function(data) {
         fatherid=data[0].id;
         addTabM(data[0].name,data[0].id); 
         show_everyp(data[0].id);
      },                                                                            
      error:function() {                                                          
         alert("get latest product error");                                  
      }                                                                        
   });

   win = $('#eidt-window').window({
      width: 530,
      height: 330,
      closed: true,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      modal: true,
      shadow: false
   });
   form = win.find('form');

   updatewin = $('#update-product-window').window({
      width: 530,
      height: 330,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      closed: true,
      modal: true,
      shadow: false
   });
   updateform = updatewin.find('form');

utwin = $('#update-Ts-window').window({
      width: 530,
      height: 330,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      closed: true,
      modal: true,
      shadow: false
   });
   utform = utwin.find('form');



   repowin = $('#add-repo-window').window({
      width: 530,
      height: 350,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      closed: true,
      modal: true,
      shadow: false
   });
   repoform = repowin.find('form');

   baseoswin = $('#add-baseos-window').window({
      width: 530,
      height: 350,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      closed: true,
      modal: true,
      shadow: false
   });
   baseosform = baseoswin.find('form');

   deletewin = $('#delete-window').window({
      closed: true,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      modal: true,
      shadow: false
    });

   updatebaseoswin = $('#update-baseos-window').window({
      width: 530,
      height: 350,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      closed: true,
      modal: true,
      shadow: false
   });
   updatebaseosform = updatebaseoswin.find('form');

   uploadwin = $('#upload-window').window({
      width: 500,
      height: 250,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      closed: true,
      modal: true,
      shadow: false
   });
   uploadform = uploadwin.find('form');

   scotzillaWin = $('#scotzilla-window').window({
      width: 500,
      height: 250,
      collapsible:false,  
      minimizable:false,  
      maximizable:false, 
      closed: true,
      modal: true,
      shadow: false
   });
})

function show_latest_product(){
//for create new product 
 $.ajax({
         url: '/products/1/get_latest_product',
         type:'get',
         success:function(data) {
            fatherid=data[0].id;
            addTabM(data[0].name,data[0].id);
            show_everyp(data[0].id);
         },
         error:function() {
            alert("Get latest product error");
         }
      });
}

function refresh_delete(){
   childid="";
   node_type="";
   var repo_copy;
   repo_data=repo_copy;
   addTabM(product_value.name,product_value.id);
   show_everyp(product_value.id);
   $('#tt').tree('reload'); 
   grid.datagrid('reload');
}

function refresh_product_all(){
   $('#tt').tree('reload');
   show_everyp(product_value.id);
}


function InitLeftMenu() {
   $('.easyui-accordion li a').click(function () {
      var tabTitle = $(this).text();
      var url = $(this).attr("href");
      $('.easyui-accordion li div').removeClass("selected");
      $(this).parent().addClass("selected");
   }).hover(function () {
      $(this).parent().addClass("hover");
      }, function () {
         $(this).parent().removeClass("hover");
      });
}

function InitTreeData(){
   $('#tt').tree({
      method:"get",
      url:'/products',
      onLoadSuccess:function(){
		var node = $(this).tree('find', selectedNodeId);
		if (node){
			$(this).tree('select', node.target);
		}
	},
	onSelect:function(node){
		selectedNodeId = node.id;
	},
      onClick: function(node){
         $(this).tree('toggle', node.target);
         p = $(this).tree('getParent', node.target);
         if(p){
            fatherid=p.id;
            childid=node.id;
            node_type=node.attributes.data;
            if(node_type=="VMWsource"){ 
               $.ajax({    
                  type:'get',    
                  url:'repos/'+childid+'',    
                  dataType:'json',    
                  success:function(data){    
                     repo_data=data;
                     if(node.attributes.data=="VMWsource"){
                        show_packages("repos/"+node.id+"/repo_packages");
                     }else{
                        show_packages("containers/"+node.id+"/container_packages");
                     }
                  },    
                  error:function(data){
                     alert(data.msg);
                  }    
               });
            }else{
	       $.ajax({    
                  type:'get',    
                  url:'containers/'+childid,    
                  cache:false,    
                  dataType:'json',    
                  success:function(data){    
                     repo_data=data;
                     if(node.attributes.data=="VMWsource"){
                        show_packages("repos/"+node.id+"/repo_packages");
                     }else{
                        show_packages("containers/"+node.id+"/container_packages");
                     }
                  },    
                  error:function(){}    
               });
            }
         addTab(node.text , childid);
      }else{
         var fadata;
         repo_data= fadata ;
         fatherid=node.id;
         addTabM(node.text,fatherid);
         show_everyp(fatherid);
         $('#product').attr('title',fatherid);
      }  
      }
   });
}

function show_everyp(fatherid){
    var chart;
    var productid; 
    var container_done;
    var container_undone;
    var repo_done;
    var repo_undone;
    var repo_mt_done;
    var repo_mt_all;
    var repo_ut_done;
    var repo_ut_all;
    var chatcount =0 ;
    var repo_total=0; 
 
productid=fatherid;
 $.ajax({                                                 
     url: '/products/'+productid+'/container_total',                               
     type:'get',                                                                   
     success:function(data1) {     
      if(data1[0].title=="Done"){
         container_done=data1[0].count;
         container_undone=data1[1].count;
      }else{
         container_done=data1[1].count;
         container_undone=data1[0].count;
           }

if((container_done+container_undone)==0 || container_done==0){
   chatcount=0;
}else{
   chatcount=Math.round(container_done*100)/(Math.round(container_done)+Math.round(container_undone)) ;
}
$.ajax( {                                                 
     url: '/products/'+productid+'/repo_total',                               
     type:'get',                                                                   
     success:function(data2) {      
      if(data2[0].title=="Done"){
         repo_done=data2[0].count;
         repo_undone=data2[1].count;
      }else{
         repo_done=data2[1].count;
         repo_undone=data2[0].count;
           }

if((repo_done+repo_undone)==0 || repo_done==0){
   repo_total=0;
}else{
   repo_total=repo_done*100/(Math.round(repo_done)+Math.round(repo_undone)) ;
}
 $.ajax( {                                                 
     url: '/products/'+productid+'/repo_mt_total',                               
     type:'get',                                                                   
     success:function(data3) {      
      if(data3[0].title=="Done"){
         repo_mt_done=data3[0].count;
      }else{
         repo_mt_done=data3[1].count;
           }
      repo_mt_all=Math.round(data3[0].count)+Math.round(data3[1].count);

$.ajax( {                                                 
     url: '/products/'+productid+'/repo_ut_total',                               
     type:'get',                                                                   
     success:function(data4) {      
      if(data4[0].title=="Done"){
         repo_ut_done=data4[0].count;
      }else{
         repo_ut_done=data4[1].count;
           }
       repo_ut_all=Math.round(data4[0].count)+Math.round(data4[1].count);
      var colors = Highcharts.getOptions().colors,
            categories = ['CF-Component', 'BaseOS Container'],
            data = [{
                    y: Math.round(repo_total),
                    color: colors[5],
                    drilldown: {
                        name: 'CF-Component Progress',
                        categories: ['Done', 'Total'],
                        color: colors[0]
                    }
                }, {
                    y: Math.round(chatcount),
                    color: colors[8],
                    drilldown: {
                        name: 'BaseOS container Progress',
                        categories: ['Done', 'Total'],
                        color: colors[1]
                    }
                }];
        chart = new Highcharts.Chart({
            chart: {
                renderTo: 'container',
                type: 'column',
                width:400,
                height:300
            },
            title: {
                text: 'Overview'
            },
            xAxis: {
                categories: categories
            },
            yAxis: {
                title: {
                    text: 'Total percent of progress'
                }
            },
            credits: {
              enabled: false
             },
            legend: {
               enabled: false
             },
            plotOptions: {
                column: {
                    dataLabels: {
                        enabled: true,
                        color: colors[0],
                        style: {
                            fontWeight: 'bold'
                        },
                        formatter: function() {
                            return this.y +'%';
                        }
                    }
                }
            },
            tooltip: {
                formatter: function() {
                    var point = this.point,
                        s = this.x +':<b>'+ this.y +'%  </b><br/>';
                    return s;
                }
            },
            series: [{
                name: name,
                data: data,
                color: 'white'
            }],
            exporting: {
                enabled: false
            }
        });
   
 chart = new Highcharts.Chart({
            chart: {
                renderTo: 'container1',
                type: 'column',
                width:400,
                height:300
            },
            title: {
                text: ' Details progress'
            },
            exporting:{ 
                     enabled:false  
            },
            xAxis: {
                categories: [
                    'CF-Component MTs',
                    'CF-Component UTs',
                    'BaseOS MTs'
                ]
            },
            credits: {
              enabled: false
             },
            yAxis: {
                min: 0,
                title: {
                    text: 'Progress of details for MTs plus UTs '
                }
            },
            legend: {
                layout: 'vertical',
                backgroundColor: '#FFFFFF',
                align: 'left',
                verticalAlign: 'top',
                x: 315,
                y: 10,
                floating: true,
                shadow: true
            },
            tooltip: {
                formatter: function() {
                    return ''+
                        this.x +':'+ this.y ;
                }
            },
            plotOptions: {
                column: {
                    pointPadding: 0.2,
                    borderWidth: 0
                }
            },
                series: [{
                name: 'Done',
                data: [Math.round(repo_mt_done),Math.round(repo_ut_done),Math.round(container_done)],
                color:colors[13]
            }, {
                name: 'Total',
                data: [Math.round(repo_mt_all),Math.round(repo_ut_all),Math.round(Math.round(container_done)+Math.round(container_undone))],
                color:colors[6]
            }
            ]
        });

$('#productinfo').datagrid({
                    url: 'products/'+productid+'/repo_details_of_product',
                    method:'Get',
                    nowrap: true,             
                    striped: true, 
                    collapsible:true,
                    singleSelect:true,
                    onClickCell: function (rowIndex, field, value) {
                       if(field=="name"){
                         //open the repo page
                          var row = $("#productinfo").datagrid("getData");
                          childid=row.rows[rowIndex].id;
            if(row.rows[rowIndex].category == "VMWsource"){ 
               $.ajax({    
                  type:'get',    
                  url:'repos/'+childid+'',    
                  dataType:'json',    
                  success:function(data){    
                     repo_data=data;
                        show_packages("repos/"+childid+"/repo_packages");
                  },    
                  error:function(data){
                     alert(data.msg);
                  }    
               });
            }else{
	       $.ajax({    
                  type:'get',    
                  url:'containers/'+childid,    
                  cache:false,    
                  dataType:'json',    
                  success:function(data){    
                     repo_data=data;
                        show_packages("containers/"+childid+"/container_packages");
                  },    
                  error:function(){}    
               });
            }
         addTab(value , childid);







 
                       }else{
                          row=null;
                       }
                     },
                    columns: [[
                        { field: "name", title: "Name", width:180  },
                        { field: "mt_status", title: "MT status",width:180 },
                        { field: "ut_status", title: "UT status", width:180},
                        { field: "bugzilla_status",title: "Product status",width:180},
                        { field: "add_mt", title: "Master Ticket", width:135 },
                        { field: "add_ut", title: "Use Ticket", width:135 },
                    ]]                   
                });
      },                                                                            
      error:function() {                                                          
           alert("get repo_ut_total  error");                                  
      }                                                                        
 });

      },                                                                            
      error:function() {                                                          
           alert("get repo_mt_total  error");                                  
      }                                                                        
 });

      },                                                                            
      error:function() {                                                          
           alert("get repo_total  error");                                  
      }                                                                        
 });
      },                                                                            
      error:function() {                                                          
           alert("get container_total  error");                                  
      }                                                                        
 });

}

function closeutWindow() {
   scotzillaWin.window('close');
}

function closeWindow() {
   win.window('close');
}

function closeupdateWindow() {
   updatewin.window('close');
}

function closerepoWindow() {
   repowin.window('close');
}

function closedeleteWindow() {
   deletewin.window('close');
}

function closebaseosWindow() {
   baseoswin.window('close');
}

function closeupdatebaseosWindow() {
   updatebaseoswin.window('close');
}

function closefileWindow() {
   uploadwin.window('close');
}

function closetsWindow(){
   utwin.window('close');
}


function saveData(op_type) {
   var node = $('#tt2').tree('getSelected');
      if(op_type=="update"){
         if(trim($("#update_name").val()) == "" || trim($("#update_version").val())=="" || trim($('#update_release_date').datebox('getValue'))==""){
            alert("Name Version release_date  are necessary ! ");
            return ;
         }
         if(($("#update_name").val().length > 50) || ($("#update_version").val().length>50)  ){
            alert("Name and Version must <= 50 Characters "); 
            return ;
         }

 $.ajax({
            type:"POST",
            dataType: "json",
            url:"/products/"+product_value.id+"/update_product_info",
            data:{'product[name]': trim($("#update_name").val()), 'product[version]': trim($("#update_version").val()),'product[bugzilla_url]': trim($("#update_bugzilla_url").val()),'product[bugzilla_status]': trim($("#update_bugzilla_status").val()),'product[release_date]': trim($('#update_release_date').datebox('getValue')),'product[description]': trim($("#update_description").val())},
            success:function(data){
                 if(data.stat=="ok"){
                    addTabM(trim($("#update_name").val()),fatherid);
                    show_everyp(fatherid);
                    product_value.name=trim($("#update_name").val());
                    product_value.version=trim($("#update_version").val());
                    product_value.bugzilla_url=trim($("#update_bugzilla_url").val());
                    product_value.bugzilla_status=trim($("#update_bugzilla_status").val());
                    product_value.release_date=trim($('#update_release_date').datebox('getValue'));
                    product_value.description=trim($("#update_description").val());
                    var pdata;
                    product_value=pdata; 
                    $('#tt').tree('reload');
                    closeupdateWindow();
                    updateform.form('clear');
                 }else{
                    alert(data.msg);
                 }
            },
            error:function(data){
                  alert("Please check your network !");
             }
});

   return;
   }
     if(trim($("#new_name").val()) == "" || trim($("#new_version").val())=="" || trim($('#new_release_date').datebox('getValue'))==""){
        alert("Name Version release_date  are necessary ! ");
         return ;
     }
     if(($("#new_name").val().length > 50) || ($("#new_version").val().length>50)  ){
        alert("Name and Version must <= 50 Characters "); 
        return ;
     }
 

 $.ajax({
            type:"POST",
            dataType: "json",
            url:"/products",
            data:{'product[name]': trim($("#new_name").val()), 'product[version]': trim($("#new_version").val()),'product[bugzilla_url]': trim($("#new_bugzilla_url").val()),'product[bugzilla_status]': trim($("#new_bugzilla_status").val()),'product[release_date]': trim($('#new_release_date').datebox('getValue')),'product[description]': trim($("#new_description").val())},
            success:function(data){
              if(data.stat=="ok"){
                 win.window('close');
                 $('#tt').tree('reload');
                 show_latest_product();    
              }else{
                 alert(data.msg);
              }   

            },
            error:function(data){
             alert("Please check your network !"); 
             }
});

}


function savedeleteData(){
   Delete_repo_con();
}

function setselected(){
      var selected = $('#tt').tree('getChecked');
      $('#tt').tree('check',selected.target)  
   }  


function savebaseosData(){
   var node = $('#tt').tree('getSelected');
   var createurl;
   var types;
   if(repo_data){
      if(trim($("#update_baseos_name").val())=="" || trim($("#update_baseos_version").val())==""){
         alert("baseos_name baseos_version are necessary");
         return ;
      }
      if($("#update_baseos_name").val().length > 50 || $("#update_baseos_version").val().length > 50){
         alert("baseos_name baseos_version must < 50  Characters");
         return ;
      }

 $.ajax({
            type:"POST",
            dataType: "json",
            url:"containers/"+repo_data.id+"/update_container_info",
            data:{ "container" : { 'product_id': fatherid,'name': trim($("#update_baseos_name").val()), 'version': trim($("#update_baseos_version").val()),'ct_status': trim($("#update_ct_status").val())}},
            success:function(data){
               if(data.stat=="ok"){
                  updatebaseoswin.window('close');
                  reload_datagrid();
                  updatebaseosform.form('clear');
//////////////////////////////////////////////////////////////////////////
                  $('#tt').tree('reload');
/////////////////////////////////////////////////////////////////////////

               }else{
                   updatebaseoswin.window('close');
                   alert(data.msg);
                   $('#tt').tree('reload');
                   addTabM(product_value.name,product_value.id);
                   show_everyp(product_value.id);
               }
            },
            error:function(data){
              alert("Please check your network !");
             }
       });
       return;
   }

   if(trim($("#new_baseos_name").val())=="" || trim($("#new_baseos_version").val())==""){
         alert("baseos_name baseos_version are necessary");
         return ;
   }
   if($("#new_baseos_name").val().length > 50 || $("#new_baseos_version").val().length > 50){
         alert("baseos_name baseos_version must < 50  Characters");
         return ;
   }

   $.ajax({
            type:"POST",
            dataType: "json",
            url:"containers",
            data:{ "container" : { 'product_id': fatherid,'name': trim($("#new_baseos_name").val()), 'version': trim($("#new_baseos_version").val())}},
            success:function(data){
               if(data.stat=="ok"){
                  baseoswin.window('close'); 
                  refresh_product_all();
               }else{
                  alert(data.msg);
               }
            },
            error:function(data){
               alert("Please check your network !");
            }
         });
}


function  reload_datagrid(){
   if(node_type=="VMWsource"){
      repo_data.name=trim($("#new_repo_name").val());
      repo_data.version=trim($("#new_repo_version").val());
      repo_data.bugzilla_url=trim($("#new_repo_bugzilla_url").val());
      repo_data.bugzilla_status=trim($("#new_repo_bugzilla_status").val());
      repo_data.mt_id=trim($("#new_repo_mt_id").val());
      repo_data.ut_id = trim($("#new_repo_ut_id").val());
      addTab(repo_data.name , childid);
      show_packages("repos/"+childid+"/repo_packages");
   }else{
      repo_data.name=trim($("#update_baseos_name").val());
      repo_data.version=trim($("#update_baseos_version").val());
      repo_data.ct_status=trim($("#update_ct_status").val());
      addTab(repo_data.name , childid);
      show_packages("containers/"+childid+"/container_packages");
   }
}

function reload_updatemut(){
   if(node_type=="VMWsource"){
      addTab(repo_data.name , childid);
      show_packages("repos/"+childid+"/repo_packages");
   }else{
      addTab(repo_data.name , childid);
      show_packages("containers/"+childid+"/container_packages");
   }
}


function saverepoData() {
   var node = $('#tt').tree('getSelected');
   var createurl;
   var types;
   if(trim($("#new_repo_name").val())=="" || trim($("#new_repo_version").val())==""){
      alert("repo_name repo_version are necessary");
      return ;
   }
   if($("#new_repo_name").val().length > 50  || $("#new_repo_version").val().length > 50){
      alert("repo_name repo_version must < 50 Characters");
      return ;
   }

   if(repo_data){
      $.ajax({
            type:"POST",
            dataType: "json",
            url:"repos/"+repo_data.id+"/update_repo_info",
            data:{ "repo" :{ 'product_id': fatherid,'name': trim($("#new_repo_name").val()), 'version': trim($("#new_repo_version").val()),'bugzilla_url': trim($("#new_repo_bugzilla_url").val()),'bugzilla_status': trim($("#new_repo_bugzilla_status").val()),'mt_id': trim($("#new_repo_mt_id").val()),'ut_id': trim($("#new_repo_ut_id").val())}},
            success:function(data){
               if(data.stat=="ok"){
                  repowin.window('close');
                  reload_datagrid();
                  repoform.form('clear'); 
                  $('#tt').tree('reload');
               }else{
                  repowin.window('close');
                  alert(data.msg);
                  $('#tt').tree('reload');
                  addTabM(product_value.name,product_value.id);
                  show_everyp(product_value.id)
               }
            },
            error:function(data){
               alert("Please check your network !"); 
             }
           });
           return;
   }

$.ajax({
            type:"POST",
            dataType: "json",
            url:"repos",
            data:{ "repo" :{ 'product_id': fatherid,'name': trim($("#new_repo_name").val()), 'version': trim($("#new_repo_version").val()),'bugzilla_url': trim($("#new_repo_bugzilla_url").val()),'bugzilla_status': trim($("#new_repo_bugzilla_status").val()),'mt_id': trim($("#new_repo_mt_id").val()),'ut_id': trim($("#new_repo_ut_id").val())}},
            success:function(data){
               if(data.stat=="ok"){
                  repowin.window('close'); 
                  refresh_product_all();
               }else{
                  alert(data.msg);
               }
            },
            error:function(data){
               alert("Please check your network !");
             }
       });
}


function add_product(){
   win.window('open');
   form.form('clear');
   $("#new_bugzilla_status").val(0);
}


function Create_BaseOS(){
   if(fatherid){
      baseoswin.window('open');
      baseosform.form('clear');
   }else{
      alert("Please select a product to create container .");
   }
}


function Create_Repo() {
   if(fatherid){
      repowin.window('open');
      repoform.form('clear');
      $("#new_repo_bugzilla_status").val(0);
      $("#new_repo_mt_id").val(0);
      $("#new_repo_ut_id").val(0);
   }else{
      alert("Please select a product to create repo .");
   }
}

function trim(str){ 
   return str.replace(/(^\s*)|(\s*$)/g, "");
}

function setos(os){
if(os=="baseos"){
   document.getElementById("select_target").style.display='';
   //$("#select_target").val('ubuntu');
  
}else{
   document.getElementById("select_target").style.display='none';
}

}


function handleFiles(files) {
   if (files.length) {
      var file = files[0];
      var reader = new FileReader();
      if (/text\/\w+/.test(file.type)) {
         reader.onload = function() {
            var words = this.result.split('\n');
            var checkValue=$("#select_id").val();
            var postdata;
            if(node_type=="VMWsource"){ 
               postdata='{"repo_id":"'+childid+'","category":"'+checkValue+'","list":[';
            }else{
               postdata='{"container_id":"'+childid+'","target":"'+$("#select_target").val()+'","category":"'+checkValue+'","list":[';
            }
            var a ="";
            for(var i=0; i<words.length; i++)
            { 
               a=trim(words[i]);
               if(a!=""){
                  postdata=postdata+'{"package":'+'"'+trim(a)+'"},';
                  a="";           
               }
            }
            postdata=postdata.substr(0,postdata.length-1) + "]}";
            //alert(postdata);
            document.getElementById('filecontent').value = postdata;
         }
         reader.readAsText(file);
      }
   }
}


function upload_package_button() {
   if(childid){
      uploadwin.window('open');
      uploadform.form('clear');
   }else{
      alert("Please select a repo or container to upload package list file .");
   }
}

function ajaxLoading(){  
   $("<div class=\"datagrid-mask\"></div>").css({display:"block",width:"100%",height:$(window).height()}).appendTo("body");  
   $("<div class=\"datagrid-mask-msg\"></div>").html("verifying...").appendTo("body").css({display:"block",left:($(document.body).outerWidth(true) - 190) / 2,top:($(window).height() - 45) / 2});  
}  

function ajaxLoadEnd(){  
   $(".datagrid-mask").remove();  
   $(".datagrid-mask-msg").remove();              
}



function savefileData() {
   var node = $('#tt2').tree('getSelected');
   var uploadurl;
   if(node_type=="VMWsource"){
      uploadurl="repos/"+childid+"/repo_packages_list_upload";
   }else{
      uploadurl="containers/"+childid+"/container_packages_list_upload";
   }
   //close dialog first
   uploadwin.window('close');
   //show loading div
   $.ajax( {    
      url: uploadurl, 
      data:  { 'packagelist' : document.getElementById('filecontent').value },    
      type:'post',    
      dataType:'json',   
      beforeSend:ajaxLoading, 
      success:function(data) { 
         if(data.stat=="ok"){ 
            uploadwin.window('close'); 
            grid.datagrid('reload');
            //hide the loading message
            ajaxLoadEnd(); 
            alert(data.msg);
         }else{
            uploadwin.window('close');
            ajaxLoadEnd();
            alert(data.msg);
            $('#tt').tree('reload');
            addTabM(product_value.name,product_value.id);
            show_everyp(product_value.id)
         }
      },    
      error:function(data) {    
         alert("Upload packages list Error, Please Check your connection to Scotzilla  "); 
         ajaxLoadEnd();    
      }    
   }); 
}

function Sync_from_Scotzilla() {
var url="";
   if(childid){
      if(node_type=="VMWsource"){
         url="/repos/"+childid+"/repo_packages_filling_missing";
      }else{
         url="/containers/"+childid+"/container_packages_filling_missing";
      }
   }else{
      alert("Please select a repo or container  to Sync data from Scotzilla .");
      return;
   }

$.ajax({
  url: url,
  type: 'get',
  beforeSend:ajaxLoading,
  success: function(data){
    if(data.stat=="ok"){ 
       grid.datagrid('reload');
       ajaxLoadEnd();
       alert(data.msg); 
    }else{
       ajaxLoadEnd();
       alert(data.msg);
       $('#tt').tree('reload');
       addTabM(product_value.name,product_value.id);
       show_everyp(product_value.id)
    }
  },
  error: function(data){
     alert("Sync Error Please check your network , Make sure you can access SCOTzilla !");
  }
});

}


function File_Uts_Scotzilla() {
   if(childid){
      if(node_type=="VMWsource"){
         //alert("can file uts");
         scotzillaWin.window('open');
      }else{
         alert("Not VMWsource packages So can't file uts");
      }
   grid.datagrid('reload');
   }else{
      alert("Please select a repo to File Uts.");
   }
}

function fileUtsData() {
   var node = $('#tt2').tree('getSelected');
   var uploadurl;
   if(node_type=="VMWsource"){
      uploadurl="repos/"+childid+"/repo_packages_file_ut";
      var str = '{"username":"'+trim($("#username").val())+'","password":"'+trim($("#password").val())+'"}'
      scotzillaWin.window('close');
      ajaxLoading();
      $.ajax( {    
         url: uploadurl, 
         data:  { 'user' : str },    
         type:'post',    
         dataType:'json',   
         beforeSend:ajaxLoading, 
         success:function(data) { 
            if(data.stat=="ok"){ 
               uploadwin.window('close'); 
               grid.datagrid('reload');
               //hide the loading message
               ajaxLoadEnd(); 
               alert(data.msg);
            }else{
               uploadwin.window('close');
               ajaxLoadEnd();
               alert(data.msg);
               //$('#tt').tree('reload');
               //addTabM(product_value.name,product_value.id);
               //show_everyp(product_value.id)
            }
         },    
         error:function() {    
            alert("File Uts Error Please Check your connection to Scotzilla");   
            ajaxLoadEnd();  
            alert(data.msg);
         }    
      });               
   }else{
 	   alert("Not VMWsource repo . "); 
        } 
}

function Delete_repo_dialog(){
   deletewin.window('open'); 
}


function Delete_repo_con() {
var url="";
if(childid){
   if(node_type=="VMWsource"){
      url="/repos/"+childid+"/delete_repo";
   }else{
      url="/containers/"+childid+"/delete_container";
   }
   deletewin.window('close'); 
}else{
   alert("Please select a repo or container  to delete from Scotzilla-Tracker System .");
   return;
}

$.ajax({
    url: url,
    type: "GET",
    success: function (msg) {
    refresh_delete();    
},
    error: function (msg){
    refresh_delete();   
 }
});

}



function Update_repo(childid){
   if(repo_data.status==1){
      alert("Repo already finished !");
      return ;
   }
   repowin.window('open');
   repoform.form('clear');
   $("#new_repo_name").val(repo_data.name); 
   $("#new_repo_version").val(repo_data.version);
   $("#new_repo_bugzilla_url").val(repo_data.bugzilla_url); 
   $("#new_repo_bugzilla_status").val(repo_data.bugzilla_status);
   $("#new_repo_category").val(node_type);
   $("#new_repo_mt_id").val(repo_data.mt_id); 
   $("#new_repo_ut_id").val(repo_data.ut_id);
}


function Edit_product(fatherid){
   if(product_value.status==1){
      alert("Product already finished !");
      return;
   }

   updatewin.window('open');
   updateform.form('clear');
   $("#update_name").val(product_value.name); 
   $("#update_version").val(product_value.version);
   $("#update_bugzilla_url").val(product_value.bugzilla_url); 
   $("#update_bugzilla_status").val(product_value.bugzilla_status);
   $("#update_release_date").datebox("setValue",product_value.release_date);
   $("#update_description").val(product_value.description); 
}


function Update_baseos(childid){
   if(repo_data.status==1){
      alert("BaseOS already finished !");
      return ;
   }
   updatebaseoswin.window('open');
   updatebaseosform.form('clear');
   $("#update_baseos_name").val(repo_data.name); 
   $("#update_baseos_version").val(repo_data.version);
   $("#update_ct_status").val(repo_data.ct_status);
}



function show_packages(repo) {
   var toolbardata;
   if(node_type=="VMWsource"){
      var utbutton="";
      $.ajax({    
         url: 'repos/'+repo_data.id+'/repo_packages', 
         type:'get',    
         dataType:'json',   
         success:function(data) {
            var mtstatus=1;
            for(var i=0; i<data.total; i++){
               if (data.rows[i]['Master Ticket']==0){
                  mtstatus=0;
                  break;
               }
            }
            if(repo_data.bugzilla_status==2 && mtstatus==1 ){
               utbutton="<button   id='file_ut'   onclick='File_Uts_Scotzilla()'>File Uts</button>";
            }else{
               utbutton="<button  id='file_ut'  style='display:none;'  onclick='File_Uts_Scotzilla()'>File Uts</button>";
            }
            var bstatus;
            if(repo_data.bugzilla_status==0){
	       bstatus="<text  style='color:red'> Product_status:Not applied</text>";
            }else if(repo_data.bugzilla_status==1){
	       bstatus="<text  style='color:red'>Product_status:Applied</text>";
            }else{
	       bstatus="Product_status:Approved";
            } 
            
            var mtcolor="";
            var utcolor="";
            if(repo_data.mt_id == 0){
               mtcolor="<text  style='color:red'>mt_id:0</text>";
            }else{
               mtcolor=" mt_id:"+repo_data.mt_id ;
            }
            if(repo_data.ut_id == 0){
               utcolor="<text  style='color:red'>ut_id:0</text>";
            }else{
               utcolor="  ut_id:"+repo_data.ut_id ;
            }
            toolbardata="<div style='height:22px;'><div  style='float:left; margin-left:0;'>Name:&nbsp&nbsp"+repo_data.name+"&nbsp&nbsp&nbsp&nbspVersion:&nbsp&nbsp "+repo_data.version+"&nbsp&nbsp"+bstatus+"&nbsp&nbsp"+mtcolor+"&nbsp&nbsp"+utcolor+"</div><div style='float:right;margin-right:0; ' ><button onclick='Update_repo("+childid+")' >Edit</button><button onclick='upload_package_button()' >Upload packages </button> <button onclick='Sync_from_Scotzilla()'>Sync</button>"+utbutton+"<button onclick='Delete_repo_dialog()'>Delete</button></div></div>";
            if(repo_data.status==1){
               toolbardata="<div style='height:22px;'><div  style='float:left; margin-left:0;'>Name:&nbsp&nbsp"+repo_data.name+"&nbsp&nbsp&nbsp&nbspVersion:&nbsp&nbsp "+repo_data.version+"&nbsp&nbsp"+bstatus+"&nbsp&nbsp"+mtcolor+"&nbsp&nbsp"+utcolor+"</div><div style='float:right;margin-right:0; ' ><button onclick='Delete_repo_dialog()'>Delete</button></div></div>";
            }
         load_packages(toolbardata,repo);
         },    
         error:function() {    
            alert("Get packages Error");    
         }    
      });               
   }else{
      var ctstatus;
      if(repo_data.ct_status==0){
         ctstatus="<text  style='color:red'>CT_status:Not applied</text>";
      }else if(repo_data.ct_status==1){
         ctstatus="<text  style='color:red'>CT_status:Applied</text>";
      }else{
         ctstatus="CT_status:Approved";
      }
      toolbardata="<div style='height:22px;'><div  style='float:left; margin-left:0;'>Name:&nbsp&nbsp"+repo_data.name+"&nbsp&nbsp&nbsp&nbspVersion:&nbsp&nbsp "+repo_data.version+"&nbsp&nbsp"+ctstatus+"</div><div style='float:right;margin-right:0; '> <button onclick='Update_baseos("+childid+")' >Edit</button><button onclick='upload_package_button()' >Upload packages </button> <button onclick='Sync_from_Scotzilla()'>Sync</button><button onclick='export_ct_tracker()'>Export CT-Tracker TXT</button><button onclick='Delete_repo_dialog()'>Delete</button></div></div>";
      if(repo_data.status==1){
       toolbardata="<div style='height:22px;'><div  style='float:left; margin-left:0;'>Name:&nbsp"+repo_data.name+"&nbsp&nbsp&nbsp&nbspVersion:&nbsp "+repo_data.version+"&nbsp&nbsp"+ctstatus+"</div><div style='float:right;margin-right:0; '> <button onclick='export_ct_tracker()'>Export CT-Tracker TXT</button><button onclick='Delete_repo_dialog()'>Delete</button></div></div>";
      }
      load_packages(toolbardata,repo);
   }
}

function downloadFile(fileName, content){
    var aLink = document.createElement('a');
    var blob = new Blob([content]);
    var evt = document.createEvent("HTMLEvents");
    evt.initEvent("click", false, false);
    aLink.download = fileName;
    aLink.href = URL.createObjectURL(blob);
    aLink.dispatchEvent(evt);
}

function export_ct_tracker(){
   var exportdata = $('#test').datagrid('getData');
   var filedata="" ;
   for(var i=0;i<exportdata.total;i++){
      if(exportdata.rows[i]["Master Ticket"]==0){
         alert("Please File Missing Mts via SCOTzilla ");
         return ;
      }else{
        if(((i+1)%8 == 0) || ((i+1) == exportdata.total)){
           filedata=filedata+exportdata.rows[i]["Master Ticket"]+"\n" ;
        }else{
           filedata=filedata+exportdata.rows[i]["Master Ticket"]+",";
        } 
      }
   }
   downloadFile(repo_data.name+"_"+repo_data.version+".txt",filedata);
}

function dbclick_editmts(){
   utform.form('clear');
   document.getElementById("ts_ut_id").style.display='';
   document.getElementById("td_ts_ut_id").style.display='';
   document.getElementById("ts_package_id").style.display='none';
   document.getElementById("ts_package_td_id").style.display='none';
   var currentRow =$("#test").datagrid("getSelected");
   $("#ts_package_id").val(currentRow.id);
   if(node_type =='VMWsource'){
      //alert( currentRow.id+"---"+currentRow.name+"---"+currentRow.version+"---"+currentRow['Master Ticket']+"---"+currentRow['Use Ticket']);
       $("#ts_mt_id").val(currentRow['Master Ticket']);
       $("#ts_ut_id").val(currentRow['Use Ticket']);
   }else{
      //alert( currentRow.id+"---"+currentRow.name+"---"+currentRow.version+"---"+currentRow['Master Ticket']);
      $("#ts_mt_id").val(currentRow['Master Ticket']);
      $("#ts_ut_id").val('0');
      document.getElementById("ts_ut_id").style.display='none';       
      document.getElementById("td_ts_ut_id").style.display='none';       
   }
   utwin.window('open');
}

function IsNum(s){
    if (s!=null && s!="")
    {
        return !isNaN(s);
    }
    return false;
}

function savetsData(){
   if(!IsNum(trim($("#ts_mt_id").val())) || !IsNum( trim($("#ts_ut_id").val()) ) ){
      alert("Please enter numbers for Tickets ID !"); 
      return; 
   }
   scotzillaWin.window('close');
   ajaxLoading();
   $.ajax( {    
      url: "products/"+product_value.id+"/update_package", 
      data:  { 'modify' : {"category" : node_type,"package_id" : trim($("#ts_package_id").val()) ,"mt_id" : trim($("#ts_mt_id").val()),"ut_id" : trim($("#ts_ut_id").val()) } }, 
      type:'post',    
      dataType:'json',   
      beforeSend:ajaxLoading, 
      success:function(data) {  
         utwin.window('close');
         reload_updatemut(); 
         //hide the loading message
         ajaxLoadEnd(); 
         alert(data.msg);
      },    
      error:function(data) {    
         alert("Update Tickets ID Error Please Check your connection to Scotzilla");   
         ajaxLoadEnd(); 
         utwin.window('close'); 
         alert(data.msg);
      }    
   });   
}

function load_packages(toolbardata,repo){
if(node_type=="VMWsource"){
   grid = $('#test').datagrid({
      title:toolbardata,
      nowrap: true,
      striped: true,
      //collapsible:true,
      singleSelect:true,
      onLoadSuccess: function(data) {
      show_status_dialog();
             }, 
      method: 'get',
      url:repo,
      remoteSort: false,
      idField:'id',
      onDblClickCell: function(rowIndex,field,value){
        dbclick_editmts(); 
   	},
      columns:[[
         {field:'id',title:'ID',width:100,sortable:true},
         {field:'name',title:'Name',width:250,sortable:true},
         {field:'version',title:'version',width:250},
         {field:'Master Ticket',title:'Master Ticket',width:200,sortable:true},
         {field:'Use Ticket',title:'Use Ticket',width:200,sortable:true},
      ]],
   });}else{
   grid = $('#test').datagrid({
      title:toolbardata,
      nowrap: true,
      striped: true,
      //collapsible:true,
      singleSelect:true,
      onLoadSuccess: function(data) {
         show_status_dialog();
             },
      method: 'get',
      url:repo,
      remoteSort: false,
      idField:'id',
      onDblClickCell: function(rowIndex,field,value){
        dbclick_editmts(); 
   	},
      columns:[[
         {field:'id',title:'ID',width:100,sortable:true},
         {field:'name',title:'Name',width:350,sortable:true},
         {field:'version',title:'version',width:350},
         {field:'Master Ticket',title:'Master Ticket',width:300,sortable:true},
      ]],
    });
   }
}


function show_status_dialog(){
   var exportdata = $('#test').datagrid('getData');
   var utdata=0 ;
   var mtdata=0;
   var shower="";
   for(var i=0;i<exportdata.total;i++){
       if(exportdata.rows[i]["Master Ticket"] != 0){
          mtdata=mtdata+1;  
       }
       if(exportdata.rows[i]["Use Ticket"] != 0){
          utdata=utdata+1;
       }
   }

  if(node_type=="BaseOS"){
     if(mtdata == exportdata.total){
        shower="<text class='highcharts-title'  style='color:#274b6d;font-size:20px;fill:#274b6d;width:336px;align:left;' >MTs:"+mtdata+"/"+exportdata.total+"</text>"; 
     }else{
        shower="<text class='highcharts-title'  style='color:red;font-size:20px;fill:#274b6d;width:336px;align:left;' >MTs:"+mtdata+"/"+exportdata.total+"</text>"; 
     }
  }else{
     var mtstr="";
     var utstr="";
     if(mtdata == exportdata.total){
        mtstr="<text class='highcharts-title'  style='color:#274b6d;font-size:20px;fill:#274b6d;width:336px;align:left;' >MTs:"+mtdata+"/"+exportdata.total+"</text>";
     }else{
        mtstr="<text class='highcharts-title'  style='color:red;font-size:20px;fill:#274b6d;width:336px;align:left;' >MTs:"+mtdata+"/"+exportdata.total+"</text>";
     }
     if(utdata == exportdata.total){
        utstr="<text class='highcharts-title'  style='color:#274b6d;font-size:20px;fill:#274b6d;width:336px;align:left;'> UTs:"+utdata+"/"+exportdata.total+"</text>"
     }else{
        utstr="<text class='highcharts-title'  style='color:red;font-size:20px;fill:#274b6d;width:336px;align:left;'> UTs:"+utdata+"/"+exportdata.total+"</text>"
     }
     shower=mtstr+utstr; 
  } 

$.messager.show({  
        showSpeed : 600,  
        title : 'Tickets Status',  
        timeout : 5000,  
        msg : shower,  
        showType : 'slide',  
        style : {  
            left : '',  
            top : '',  
            right : '0px',
            bottom : '0px', 
            position:'fixed' 
        }  
    });  
}


function addTab(subtitle, fid) {
   var tabs = $("#tabs").tabs("tabs");
   var length = tabs.length;
   for(var i = 0; i < length; i++) {
      var onetab = tabs[0];
      var title = onetab.panel('options').tab.text();
      $("#tabs").tabs("close", title);
   }   
   if (!$('#tabs').tabs('exists', subtitle)) {
      $('#tabs').tabs('add', {
         title: subtitle,
         content: '<table id="test" fit="true"></table>',
         closable: true,
         width: $('#mainPanle').width() - 10,
         height: $('#mainPanle').height() - 26
      });
   } else {
      $('#tabs').tabs('select', subtitle);
   }
}

function addTabM(subtitle,fatherid) {
   var tabs = $("#tabs").tabs("tabs");
   var length = tabs.length;
   for(var i = 0; i < length; i++) {
      var onetab = tabs[0];
      var title = onetab.panel('options').tab.text();
      $("#tabs").tabs("close", title);
   }   
   $.ajax( {                                                 
      url: '/products/'+fatherid,                               
      type:'get',  
      success:function(data) {      
         product_value=data ;
         var status;
         var pstatus;
         if(data.bugzilla_status==0){
            status="<text style='color:red'>Not applied</text>";
         }else if(data.bugzilla_status==1){
                  status="<text style='color:red'>Applied</text>";
               }else{
                  status="Approved";
         }
       var product_content="";
       if(data.status==0){
         pstatus="<text style='color:red'>Initial</text>";
         product_content='<div id="everyp1"><div style="text-align:left;"><tr><td><button onclick="Create_Repo()">Create New Repo</button><button onclick="Create_BaseOS()">Create New BaseOS</button><button onclick="Edit_product('+fatherid+')">Edit</button></td></tr></div><table id="everyp2" ><tr><td id="p_message" style="width:1000px;text-align:center;"><text class="highcharts-title"  style="color:#274b6d;font-size:20px;fill:#274b6d;width:336px;align:left;" >Name : ' +data.name +'&nbsp&nbsp Version : '+data.version +'&nbsp&nbsp Product Status : '+pstatus+'&nbsp&nbspBugzilla Status: <a href='+data.bugzilla_url+' >'+ status+' </a></text> </td></tr><tr><td> <div id="container" style="display:inline-block;  margin: 0 auto"></div><div id="container1" style="display:inline-block; margin: 0 auto"></div></td></tr> <tr><td><table  id="productinfo"></table></td></tr></table></div>';
      }else{
         pstatus="Done";
         product_content='<div id="everyp1"><div style="text-align:left;"><tr><td><button onclick="Create_Repo()">Create New Repo</button><button onclick="Create_BaseOS()">Create New BaseOS</button></td></tr></div><table id="everyp2" ><tr><td id="p_message" style="width:1000px;text-align:center;"><text class="highcharts-title"  style="color:#274b6d;font-size:20px;fill:#274b6d;width:336px;align:left;" >Name : ' +data.name +'&nbsp&nbsp Version : '+data.version +'&nbsp&nbsp Product Status : '+pstatus+'&nbsp&nbspBugzilla status : <a href='+data.bugzilla_url+' >'+ status+' </a></text> </td></tr><tr><td> <div id="container" style="display:inline-block;  margin: 0 auto"></div><div id="container1" style="display:inline-block; margin: 0 auto"></div></td></tr> <tr><td><table  id="productinfo"></table></td></tr></table></div>';
      }
         if (!$('#tabs').tabs('exists', subtitle)) {
            $('#tabs').tabs('add', {
               title: subtitle,
               content: product_content,
               closable: true,
               width: $('#mainPanle').width() - 10,
               height: $('#mainPanle').height() - 26
            });
         }else {
            $('#tabs').tabs('select', subtitle);
         }
      },    
      error:function() {                                                          
         alert("get product error");                                  
      }                                                                        
   });
}

