package item

import (
	"net/url"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestAuthenTreatsCreativeWeightsAsRelativeAndOnlyChangesItemState(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	mock.ExpectPrepare(`UPDATE adv_item SET active=\? WHERE active IN \("Pass2", "New"\) AND item_id=\?`).
		ExpectExec().
		WithArgs("Yes", "7").
		WillReturnResult(sqlmock.NewResult(0, 1))

	model := &Model{}
	model.SetDB(db)
	model.ARGS = url.Values{"active": {"Yes"}, "item_id": {"7"}, "agent_level": {"2"}}
	if err := model.Authen(); err != nil {
		t.Fatal(err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}
