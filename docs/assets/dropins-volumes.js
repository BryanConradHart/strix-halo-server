// Volume mount scenario factory for the drop-in generators.
//
// Loads BEFORE the page's DROPIN_SPEC script (dropins.js loads after it,
// which is too late for spec-time factories).
//
// Builds one repeatable scenario: "Add another mount" as many times as
// needed. Each mount is a named Podman volume on local disk or backed by an
// NFS export (for example a NAS share). NFS-backed mounts emit Quadlet
// .volume files, created automatically before the service starts, so no host
// fstab entry or other post-install step is needed.
//
// config: { id, title, description, placeholder, mountPlaceholder,
// exportPlaceholder, purposes: [{ value, label, mount(name), env(name)? }] }.
window.dropinVolumeMounts = function (config) {
  const purposes = config.purposes || [];
  return {
    id: config.id,
    title: config.title,
    description: config.description,
    repeat: true,
    itemLabel: "Mount",
    addLabel: "Add another mount",
    fields: [
      ...(purposes.length ? [
        { key: "purpose", label: "What is this volume for?", type: "select", options: [{ value: "", label: "General storage (choose a mount path below)" }, ...purposes.map((p) => ({ value: p.value, label: p.label }))], prefill: (value, set) => {
          const purpose = purposes.find((p) => p.value === value);
          if (!purpose) return;
          if (purpose.defaultName) set("name", purpose.defaultName);
        } },
      ] : []),
      { key: "name", label: "Volume name", placeholder: config.placeholder, pattern: "[A-Za-z0-9][A-Za-z0-9_.-]*", patternMessage: "Use a Podman volume name: letters, numbers, dots, dashes, or underscores." },
      { key: "path", label: "Container mount path", placeholder: config.mountPlaceholder || "/srv/storage", showIf: purposes.length ? { key: "purpose", equals: "" } : undefined, pattern: "/\\S*", patternMessage: "Enter an absolute path inside the container.", prefill: (value, set) => {
        const base = value.replace(/\/+$/, "").split("/").pop();
        if (base) set("name", base.replace(/[^A-Za-z0-9_.-]/g, "-"));
      } },
      { key: "backend", label: "Storage", type: "select", options: [
        { value: "local", label: "Local disk" },
        { value: "nfs", label: "NFS share (NAS)" },
      ] },
      { key: "server", label: "NFS server", placeholder: "192.168.1.10", required: false, showIf: { key: "backend", equals: "nfs" }, pattern: "[A-Za-z0-9._-]+", patternMessage: "Enter the server's IP address or hostname." },
      { key: "export", label: "NFS export path", placeholder: config.exportPlaceholder || ":/srv/nfs/share", required: false, showIf: { key: "backend", equals: "nfs" }, pattern: ":?/\\S*", patternMessage: "Enter the export path, with or without the leading colon." },
      { key: "options", label: "NFS mount options", value: "rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14,nfsvers=4", required: false, showIf: { key: "backend", equals: "nfs" }, pattern: "[A-Za-z0-9=,.+-]+", patternMessage: "Enter comma-separated mount options." },
    ],
    validate: (groups) => {
      const problems = [];
      const names = groups.map((g) => g.name).filter(Boolean);
      if (!names.length) return ["Add at least one mount, or turn this scenario off."];
      if (new Set(names).size !== names.length) problems.push("Every mount needs a different volume name.");
      for (const g of groups) {
        if (!g.name) continue;
        if (g.backend === "nfs" && !(g.server && g.export)) problems.push(`The volume "${g.name}" is NFS-backed: enter its server and export path.`);
        if (!g.purpose && !g.path) problems.push(`The volume "${g.name}" needs a container mount path.`);
      }
      for (const p of purposes) {
        if (groups.filter((g) => g.purpose === p.value).length > 1) problems.push(`Only one volume can be ${p.article ? p.article + " " : ""}${p.label.toLowerCase()}.`);
      }
      return problems;
    },
    build: (v) => {
      const container = [];
      const files = [];
      if (v.backend === "nfs") {
        const exportPath = v.export.startsWith(":") ? v.export : `:${v.export}`;
        files.push({
          name: `${v.name}.volume`,
          content: [
            `# ${v.name}.volume`,
            "[Volume]",
            `VolumeName=${v.name}`,
            "Driver=local",
            "Type=nfs",
            `Device=${exportPath}`,
            `Options=${v.options || "defaults"}`,
          ],
        });
      }
      const purpose = purposes.find((p) => p.value === v.purpose);
      if (purpose) {
        container.push(...purpose.mount(v.name));
        if (purpose.env) container.push(...purpose.env(v.name));
      } else {
        container.push(`Volume=${v.name}:${v.path}`);
      }
      return { container, files };
    },
  };
};
