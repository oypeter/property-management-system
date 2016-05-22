package models

import (
    "time"
    "github.com/astaxie/beego/orm"
    "github.com/astaxie/beego/validation"
    "log"
    "errors"
)

type StoriedBuilding struct {
    Id        int64
    Created   time.Time     `orm:"type(datetime);auto_now_add" form:"-"`
    Modified  time.Time     `orm:"type(datetime);auto_now;null" form:"-"`
    Name      string        `orm:"unique;size(32)" form:"Name" valid:"Required;MaxSize(20);MinSize(1)"`
    Floors    int           `form:"Floors" valid:"Required"`
    Height    int           `form:"Height" valid:"Required"`
    Area      int           `form:"Area" valid:"Required"`
    BuildDate time.Time     `orm:"type(date)" form:"BuildDate" valid:"Required"`
    Remark    string        `orm:"null;size(200)" form:"Remark" valid:"MaxSize(200)"`
}

type BuildingQueryParam struct {
    Name   string
    Floors int
    Height int
    Area   int
}

func init() {
    orm.RegisterModel(new(StoriedBuilding))
}

func GetBuildingList(page int64, page_size int64, sort string, queryData BuildingQueryParam) (buildings []orm.Params, count int64) {
    o := orm.NewOrm()
    storiedBuilding := new(StoriedBuilding)
    qs := o.QueryTable(storiedBuilding)
    //log.Println(queryData)
    if len(queryData.Name) > 0{
        qs = qs.Filter("Name__contains", queryData.Name)
    }
    if queryData.Area > 0{
        qs = qs.Filter("Area", queryData.Area)
    }
    if queryData.Floors > 0 {
        qs = qs.Filter("Floors", queryData.Floors)
    }
    if queryData.Height > 0 {
        qs = qs.Filter("Height", queryData.Height)
    }
    var offset int64
    if page <= 1 {
        offset = 0
    } else {
        offset = (page - 1 ) * page_size
    }
    qs.Limit(page_size, offset).OrderBy(sort).Values(&buildings)
    count, _ = qs.Count()
    return buildings, count
}

func checkBuilding(building *StoriedBuilding) (error) {
    valid := validation.Validation{}
    b, _ := valid.Valid(&building)
    if !b {
        for _, err := range valid.Errors {
            log.Println(err.Key, err.Message)
            return errors.New(err.Message)
        }
    }
    return nil
}

func AddBuilding(b *StoriedBuilding) (int64, error) {
    if err := checkBuilding(b); err != nil {
        return 0, err
    }
    o := orm.NewOrm()
    building := new(StoriedBuilding)
    building.Area = b.Area
    building.BuildDate = b.BuildDate
    building.Floors = b.Floors
    building.Height = b.Height
    building.Name = b.Name
    building.Remark = b.Remark
    id, err := o.Insert(building)
    return id, err
}

func DeleteBuildingById(Id int64) (int64, error) {
    o := orm.NewOrm()
    status, err := o.Delete(&StoriedBuilding{Id:Id})
    return status, err
}

func UpdateBuilding(building *StoriedBuilding) (int64, error) {
    if err := checkBuilding(building); err != nil {
        return 0, err
    }
    o := orm.NewOrm()
    newBuilding := make(orm.Params)

    if building.Floors != 0 {
        newBuilding["Floors"] = building.Floors
    }

    if building.Height != 0 {
        newBuilding["Height"] = building.Height
    }

    if building.Area != 0 {
        newBuilding["Area"] = building.Area
    }

    if len(building.Name) > 0 {
        newBuilding["Name"] = building.Name
    }

    if len(building.Remark) > 0 {
        newBuilding["Remark"] = building.Remark
    }
    if !building.BuildDate.IsZero() {
        newBuilding["BuildDate"] = building.BuildDate
    }
    if len(newBuilding) == 0{
        return 0, errors.New("update field is empty")
    }
    var table StoriedBuilding
    num, err := o.QueryTable(table).Filter("Id", building.Id).Update(newBuilding)
    return num, err
}