package publishercredential

import (
	"errors"
	"net/http/httptest"
	"testing"

	"github.com/guruperl/aofei/publisherauth"
	"github.com/guruperl/genelet"
)

func TestDisabledPublisherAuthenticationProducesControlledMaintenanceError(t *testing.T) {
	filter := &Filter{}
	filter.R = httptest.NewRequest("GET", "/goto/pub/g/publishercredential?action=topics", nil)
	model := &Model{}
	err := filter.Before(model, nil, nil)
	var gerr genelet.Gerror
	if !errors.As(err, &gerr) || gerr.Code != 503 {
		t.Fatalf("disabled publisher authentication error=%#v", err)
	}
}

func TestPublisherCredentialActorUsesOnlyRolePermissionsAndVerifiedMFA(t *testing.T) {
	actor := publisherCredentialActor("pub", 42, []string{"publisher.credential.*"}, true)
	if actor.Role != "pub" || actor.ID != 42 || !actor.RecentMFA ||
		!actor.Can(publisherauth.PermissionCredentialRead) || !actor.Can(publisherauth.PermissionCredentialRotate) {
		t.Fatalf("publisher credential actor = %#v", actor)
	}
	read := publisherCredentialActor("pub", 42, []string{publisherauth.PermissionCredentialRead}, false)
	if read.RecentMFA || !read.Can(publisherauth.PermissionCredentialRead) || read.Can(publisherauth.PermissionCredentialIssue) {
		t.Fatalf("read actor = %#v", read)
	}
}
