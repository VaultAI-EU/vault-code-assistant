import { ModelDescription } from "core";
import { useContext } from "react";
import { useAuth } from "../../../context/Auth";
import { IdeMessengerContext } from "../../../context/IdeMessenger";

export function useEditBlock() {
  const ideMessenger = useContext(IdeMessengerContext);
  const { selectedProfile } = useAuth();

  return (slug?: string, sourceFile?: string) => {
    console.log(
      "[VAULTAI DEBUG] ⚙️ useEditBlock called - slug:",
      slug,
      "sourceFile:",
      sourceFile,
    );
    console.log("[VAULTAI DEBUG] ⚙️ selectedProfile:", selectedProfile);

    if (slug) {
      console.log("[VAULTAI DEBUG] ⚙️ Opening control plane URL");
      ideMessenger.post("controlPlane/openUrl", {
        path: `${slug}/new-version`,
        orgSlug: undefined,
      });
    } else if (sourceFile) {
      console.log("[VAULTAI DEBUG] ⚙️ Opening sourceFile:", sourceFile);
      ideMessenger.post("openFile", {
        path: sourceFile,
      });
    } else if (
      selectedProfile?.profileType === "local" &&
      selectedProfile?.uri
    ) {
      console.log(
        "[VAULTAI DEBUG] ⚙️ Opening selectedProfile.uri:",
        selectedProfile.uri,
      );
      ideMessenger.post("openFile", {
        path: selectedProfile.uri,
      });
    } else if (
      selectedProfile?.fullSlug?.ownerSlug &&
      selectedProfile?.fullSlug.packageSlug
    ) {
      console.log("[VAULTAI DEBUG] ⚙️ Opening control plane profile");
      ideMessenger.post("controlPlane/openUrl", {
        path: `${selectedProfile.fullSlug.ownerSlug}/${selectedProfile.fullSlug.packageSlug}/new-version`,
        orgSlug: undefined,
      });
    } else {
      // Local etc
      console.log("[VAULTAI DEBUG] ⚙️ Opening config/openProfile");
      ideMessenger.post("config/openProfile", {
        profileId: "local",
      });
    }
  };
}

export function useEditModel() {
  const editBlock = useEditBlock();

  return (model?: ModelDescription | null) => {
    console.log("[VAULTAI DEBUG] ⚙️ useEditModel called with model:", model);
    console.log("[VAULTAI DEBUG] ⚙️ model.sourceFile:", model?.sourceFile);
    editBlock(undefined, model?.sourceFile);
  };
}

export function useEditDoc() {
  const editBlock = useEditBlock();
  return (
    docConfig?: { uses?: string } | { name: string; sourceFile?: string },
  ) => {
    if (!docConfig) {
      editBlock(undefined, undefined);
      return;
    }
    if ("name" in docConfig) {
      editBlock(undefined, docConfig.sourceFile);
    } else {
      editBlock(docConfig.uses, undefined);
    }
  };
}
