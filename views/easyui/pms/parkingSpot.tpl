{{template "../public/header.tpl"}}
<script type="text/javascript">
    var URL = "/pms/parkingSpot";
    $(function () {
        //车位列表
        $("#datagrid").datagrid({
            title: '车位列表',
            url: URL + '/index',
            method: 'POST',
            pagination: true,
            fitColumns: true,
            striped: true,
            rownumbers: true,
            singleSelect: true,
            idField: 'Id',
            pagination: true,
            fit: true,
            pageSize: 20,
            pageList: [10, 20, 30, 50, 100],
            columns: [[
                {field: 'Id', title: 'ID', width: 30, sortable: true},
                {
                    field: 'ParkingLotName', title: '停车场名称', width: 40,
                    formatter: function (value, rec) {
                        if (rec != null && rec.ParkingLot != null) {
                            return rec.ParkingLot.Name;
                        } else {
                            return "";
                        }
                    }
                },
                {field: 'ParkingSpotNo', title: '车位号', width: 30, align: 'center', editor: 'text', sortable: true},
                {
                    field: 'OnwerName', title: '户主', width: 30, align: 'center',
                    formatter: function (value, rec) {
                        if (rec != null && rec.Owner != null) {
                            return rec.Owner.Name;
                        } else {
                            return "";
                        }
                    }
                },

                {field: 'CarLicencePlate', title: '车牌号', width: 30, align: 'center', sortable: true},
                {field: 'CarColor', title: '车颜色', width: 30, align: 'center', sortable: true},
                {field: 'CarName', title: '车名', width: 30, align: 'center', sortable: true},
                {field: 'Remark', title: '备注', width: 50, align: 'center', editor: 'text'}
            ]],
            onAfterEdit: function (index, data, changes) {
                if (vac.isEmpty(changes)) {
                    return;
                }
                changes.Id = data.Id;
                vac.ajax(URL + '/updateParkingSpot', changes, 'POST', function (r) {
                    if (!r.status) {
                        vac.alert(r.info);
                    } else {
                        $("#datagrid").datagrid("reload");
                    }
                })
            },
            onDblClickRow: function (index, row) {
                editrow();
            },
            onRowContextMenu: function (e, index, row) {
                e.preventDefault();
                $(this).datagrid("selectRow", index);
                $('#mm').menu('show', {
                    left: e.clientX,
                    top: e.clientY
                });
            },
            onHeaderContextMenu: function (e, field) {
                e.preventDefault();
                $('#mm1').menu('show', {
                    left: e.clientX,
                    top: e.clientY
                });
            },
            onLoadSuccess: function (data) {
//                console.log(data.total)
                if (data.total == 0) {
                    //添加一个新数据行，第一列的值为你需要的提示信息，然后将其他列合并到第一列来，注意修改colspan参数为你columns配置的总列数
                    $(this).datagrid('appendRow', {Id: '<div style="text-align:center;color:red">没有相关记录！</div>'}).datagrid('mergeCells', {
                        index: 0,
                        field: 'Id',
                        colspan: 8
                    });
                    //隐藏分页导航条，这个需要熟悉datagrid的html结构，直接用jquery操作DOM对象，easyui datagrid没有提供相关方法隐藏导航条
                    $(this).closest('div.datagrid-wrap').find('div.datagrid-pager').hide();
                }
                //如果通过调用reload方法重新加载数据有数据时显示出分页导航容器
                else $(this).closest('div.datagrid-wrap').find('div.datagrid-pager').show();
            }
        });
        //创建添加车位窗口
        $("#dialog").dialog({
            modal: true,
            resizable: true,
            top: 150,
            closed: true,
            buttons: [{
                text: '保存',
                iconCls: 'icon-save',
                handler: function () {
                    $("#form1").form('submit', {
                        url: URL + '/addParkingSpot',
                        onSubmit: function () {
                            return $("#form1").form('validate');
                        },
                        success: function (r) {
                            var r = $.parseJSON(r);
                            if (r.status) {
                                $("#dialog").dialog("close");
                                $("#datagrid").datagrid('reload');
                            } else {
                                vac.alert(r.info);
                            }
                        }
                    });
                }
            }, {
                text: '取消',
                iconCls: 'icon-cancel',
                handler: function () {
                    $("#dialog").dialog("close");
                }
            }]
        });
        //创建登记户主窗口
        $("#dialog_regist_owner").dialog({
            modal: true,
            resizable: true,
            top: 150,
            closed: true,
            buttons: [{
                text: '保存',
                iconCls: 'icon-save',
                handler: function () {
                    $("#form_regist_owner").form('submit', {
                        url: URL + '/updateParkingSpot',
                        onSubmit: function () {
                            return $("#form_regist_owner").form('validate');
                        },
                        success: function (r) {
                            var r = $.parseJSON(r);
                            if (r.status) {
                                $("#dialog_regist_owner").dialog("close");
                                $("#datagrid").datagrid('reload');
                            } else {
                                vac.alert(r.info);
                            }
                        }
                    });
                }
            }, {
                text: '取消',
                iconCls: 'icon-cancel',
                handler: function () {
                    $("#dialog_regist_owner").dialog("close");
                }
            }]
        });
        //创建选择户主窗口
        $("#dialog_choose_owner").dialog({
            modal: true,
            resizable: true,
            top: 150,
            closed: true,
            buttons: [{
                text: '确定',
                iconCls: 'icon-save',
                handler: function () {
                    if ($("#input_owner_name2").val() != "" && $("#input_owner_phone2").val() != "") {
                        $("#input_owner_phone").val($("#input_owner_phone2").val())
                        $("#input_owner_name").val($("#input_owner_name2").val())
                        $("#dialog_choose_owner").dialog("close");
                    } else {
                        vac.alert("未选择户主");
                    }
                }
            }, {
                text: '取消',
                iconCls: 'icon-cancel',
                handler: function () {
                    $("#dialog_choose_owner").dialog("close");
                }
            }]
        });

    });


    function editrow() {
        if (!$("#datagrid").datagrid("getSelected")) {
            vac.alert("请选择要编辑的行");
            return;
        }
        $('#datagrid').datagrid('beginEdit', vac.getindex("datagrid"));
    }
    function saverow(index) {
        if (!$("#datagrid").datagrid("getSelected")) {
            vac.alert("请选择要保存的行");
            return;
        }
        $('#datagrid').datagrid('endEdit', vac.getindex("datagrid"));
    }
    //取消
    function cancelrow() {
        if (!$("#datagrid").datagrid("getSelected")) {
            vac.alert("请选择要取消的行");
            return;
        }
        $("#datagrid").datagrid("cancelEdit", vac.getindex("datagrid"));
    }
    //刷新
    function reloadrow() {
        $("#datagrid").datagrid("reload");
    }

    //添加弹窗
    function addrow() {
        $("#dialog").dialog('open');
        $("#form1").form('clear');
    }


    //删除
    function delrow() {
        $.messager.confirm('Confirm', '你确定要删除?', function (r) {
            if (r) {
                var row = $("#datagrid").datagrid("getSelected");
                if (!row) {
                    vac.alert("请选择要删除的行");
                    return;
                }
                vac.ajax(URL + '/deleteParkingSpot', {Id: row.Id}, 'POST', function (r) {
                    if (r.status) {
                        $("#datagrid").datagrid('reload');
                    } else {
                        vac.alert(r.info);
                    }
                })
            }
        });
    }

    //登记户主
    function registOwner() {
        var row = $("#datagrid").datagrid("getSelected");
        if (!row) {
            vac.alert("请选择要登记的车位");
            return;
        }
//        console.log(row["Id"]);

        $("#dialog_regist_owner").dialog('open');
        $("#form_regist_owner").form('clear');
        $("#parkingSpotId").val(row["Id"]);
    }
    //撤销户主
    function repealOwner() {
        var row = $("#datagrid").datagrid("getSelected");
        if (!row) {
            vac.alert("请选择要撤销的车位");
            return;
        }
        console.log(row);
        if (row["Owner"] == null) {
            vac.alert("该车位已空")
            return;
        }
        $.post(URL + "/repealOwner", {
                    "Id": row.Id
                },
                function (r) {
                    if (r.status) {
                        $("#datagrid").datagrid('reload');
                    } else {
                        vac.alert(r.info);
                    }
                }
        )
        ;
    }

    function chooseOwner() {
        $("#dialog_choose_owner").dialog('open');
        $("#form_choose_owner").form('clear');
    }
    function Query() {
        var postData = new Object();

        if ($('#query_parking_lot_id').combobox('getValue') != '') {
            postData.parking_lot_id = $('#query_parking_lot_id').combobox('getValue');
        }

        if ($('#query_parking_spot_no').val() != '') {
            postData.parking_spot_no = $('#query_parking_spot_no').val();
        }

        if ($('#query_owner_name').val() != '') {
            postData.owner_name = $('#query_owner_name').val();
        }
        if ($('#query_car_licence_plate').val() != '') {
            postData.car_licence_plate = $('#query_car_licence_plate').val();
        }

        if ($('#query_car_color').val() != '') {
            postData.car_color = $('#query_car_color').val();
        }

        if ($('#query_car_name').val() != '') {
            postData.car_name = $('#query_car_name').val();
        }
        $('#datagrid').datagrid('load', postData);
    }
</script>
<body style="padding:2px; margin:0px;" class="panel-noscroll">
<div class="easyui-layout layout" fit="true">
    <div data-options="region:'north'" style="margin: 2px; height: 85px;">
        <div class="panel-header">
            <div class="panel-title">查询条件</div>
            <div class="panel-tool"><a href="javascript:void(0)" class="layout-button-up"></a></div>
        </div>
        <div data-options="region:'north',split:true,title:'查询条件'" style="padding: 2px;"
             title="" class="panel-body layout-body">
            <table cellpadding="3" cellspacing="3">
                <tbody>
                <tr>
                    <td>停车场名称:</td>
                    <td><input class="easyui-combobox"
                               id="query_parking_lot_id"
                               data-options="
    valueField: 'Id',
    textField: 'Name',
    url: '/pms/parkingLot/parkingLotList'
    "></td>
                    <td>车位号:</td>
                    <td><input type="text" id="query_parking_spot_no" value="" size="10"></td>
                    <td>户主:</td>
                    <td><input type="text" id="query_owner_name" value="" size="10"></td>
                </tr>
                <tr>
                    <td>车牌号:</td>
                    <td><input type="text" id="query_car_licence_plate" value="" size="20"></td>
                    <td>车颜色:</td>
                    <td><input type="text" id="query_car_color" value="" size="10"></td>
                    <td>车名:</td>
                    <td><input type="text" id="query_car_name" value="" size="10"
                               onkeydown="if(event.keyCode == 13) {Query();}"></td>

                    <td><input value="查询" type="button" id="BN_Find" style="width:80px; height:30px;" class="button"
                               onclick="Query();"></td>
                </tr>
                </tbody>
            </table>

        </div>
    </div>
    <div data-options="region:'center'" style="margin: 2px;">
        <table id="datagrid" toolbar="#tb"></table>
    </div>
</div>
<div id="tb" style="padding:5px;height:auto">
    <a href="#" icon='icon-add' plain="true" onclick="addrow()" class="easyui-linkbutton">新增</a>
    <a href="#" icon='icon-edit' plain="true" onclick="editrow()" class="easyui-linkbutton">编辑</a>
    <a href="#" icon='icon-save' plain="true" onclick="saverow()" class="easyui-linkbutton">保存</a>
    <a href="#" icon='icon-cancel' plain="true" onclick="delrow()" class="easyui-linkbutton">删除</a>
    <a href="#" icon='icon-reload' plain="true" onclick="reloadrow()" class="easyui-linkbutton">刷新</a>
    <a href="#" icon='icon-add' plain="true" onclick="registOwner()" class="easyui-linkbutton">车位登记户主</a>
    <a href="#" icon='icon-remove' plain="true" onclick="repealOwner()" class="easyui-linkbutton">车位撤销户主</a>
</div>
<!--表格内的右键菜单-->
<div id="mm" class="easyui-menu" style="width:120px;display: none">
    <div iconCls='icon-add' onclick="addrow()">新增</div>
    <div iconCls="icon-edit" onclick="editrow()">编辑</div>
    <div iconCls='icon-save' onclick="saverow()">保存</div>
    <div iconCls='icon-cancel' onclick="cancelrow()">取消</div>
    <div class="menu-sep"></div>
    <div iconCls='icon-cancel' onclick="delrow()">删除</div>
    <div iconCls='icon-reload' onclick="reloadrow()">刷新</div>
    <div class="menu-sep"></div>
    <div>Exit</div>
</div>
<!--表头的右键菜单-->
<div id="mm1" class="easyui-menu" style="width:120px;display: none">
    <div icon='icon-add' onclick="addrow()">新增</div>
</div>
<div id="dialog" title="添加车位" style="width:400px;height:400px;">
    <div style="padding:20px 20px 40px 80px;">
        <form id="form1" method="post">
            <table>
                <tr>
                    <td>停车场：</td>
                    <td>
                        <input class="easyui-combobox"
                               name="ParkingLotId"
                               id="ParkingLotId" data-options="
    valueField: 'Id',
    textField: 'Name',
    url: '/pms/parkingLot/parkingLotList'
    "></td>
                </tr>
                <tr>
                    <td>车位号：</td>
                    <td><input name="ParkingSpotNo" class="easyui-validatebox" required="true"/></td>
                </tr>
                <tr>
                    <td>备注：</td>
                    <td><textarea name="Remark" class="easyui-validatebox" validType="length[0,200]"></textarea></td>
                </tr>
            </table>
        </form>
    </div>
</div>
<div id="dialog_regist_owner" title="车位登记户主" style="width:450px;height:400px;">
    <div style="padding:20px 20px 40px 80px;">
        <form id="form_regist_owner" method="post">
            <input id="parkingSpotId" name="Id" type="hidden">
            <table>
                <tr>
                    <td>户主姓名：</td>
                    <td><input id="input_owner_name" name="OwnerName" class="easyui-validatebox" required="true"/></td>
                    <td>
                        <a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-search'"
                           onclick="chooseOwner()">选择</a>
                    </td>
                </tr>
                <tr>
                    <td>户主手机号：</td>
                    <td><input id="input_owner_phone" name="OwnerPhone" class="easyui-validatebox" required="true"/>
                    </td>
                </tr>
                <tr>
                    <td>车牌号：</td>
                    <td><input name="CarLicencePlate" class="easyui-validatebox" required="true"/></td>
                </tr>
                <tr>
                    <td>车颜色：</td>
                    <td><input name="CarColor" class="easyui-validatebox" required="true"/></td>
                </tr>
                <tr>
                    <td>车名：</td>
                    <td><input name="CarName" class="easyui-validatebox" required="true"/></td>
                </tr>
            </table>
        </form>
    </div>
</div>
<div id="dialog_choose_owner" title="户主选择" style="width:400px;height:400px;">
    <div style="padding:20px 20px 40px 80px;">
        <form id="form_choose_owner" method="post">
            <table>
                <tr>
                    <td>楼宇名称:</td>
                    <td><input class="easyui-combobox"
                               id="query_building_id"
                               style="width: 100px;"
                               data-options="
    valueField: 'Id',
    textField: 'Name',
    url: '/pms/building/buildingList',
    onSelect: function(rec){
    $('#query_unit_name').combobox('clear');
    $('#query_house_no').combobox('clear');
    var url = '/pms/building/unitList?BuildingId='+rec.Id;
    $('#query_unit_name').combobox('reload', url);
    }
    "></td>
                </tr>
                <tr>
                    <td>单元名称:</td>
                    <td><input class="easyui-combobox" id="query_unit_name" style="width:60px;" data-options="
                    valueField:'UnitName',textField:'UnitName',onSelect: function(rec){
    $('#query_house_no').combobox('clear');
    var url = '/pms/house/houseList?building_id='+rec.Building.Id+'&unit_name='+rec.UnitName;
    $('#query_house_no').combobox('reload', url);
    }
                    "></td>
                </tr>
                <tr>
                    <td>房号:</td>
                    <td><input class="easyui-combobox" id="query_house_no" style="width: 70px;"
                               data-options="valueField:'Id',textField:'HouseNo', method:'post',onSelect: function(rec){
                               $('#input_owner_name2').val(rec.Owner.Name);
                               $('#input_owner_phone2').val(rec.Owner.PhoneNumber);
    }"></td>
                </tr>
                <tr>
                    <td>户主姓名：</td>
                    <td><input id="input_owner_name2" name="OwnerName" class="easyui-validatebox" disabled="disabled"/>
                    </td>
                </tr>
                <tr>
                    <td>户主手机号：</td>
                    <td><input id="input_owner_phone2" name="OwnerPhone" class="easyui-validatebox"
                               disabled="disabled"/>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</div>
</body>
<script type="text/javascript">
    function myformatter(date) {
        var y = date.getFullYear();
        var m = date.getMonth() + 1;
        var d = date.getDate();
        return y + '-' + (m < 10 ? ('0' + m) : m) + '-' + (d < 10 ? ('0' + d) : d) + "T00:00:00Z";
    }
    function myparser(s) {
        if (!s) return new Date();
        var ss = (s.split('-'));
        var y = parseInt(ss[0], 10);
        var m = parseInt(ss[1], 10);
        var tmp = ss[2].split('T')

        var d = parseInt(tmp[0], 10);
        if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
            return new Date(y, m - 1, d);
        } else {
            return new Date();
        }
    }

</script>
</html>