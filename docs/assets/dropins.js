// Shared engine for the Quadlet drop-in generator pages.
// Each page defines a SPEC (unit, image, env file, scenarios) and calls buildPage.
(() => {
  const el = (tag, attrs = {}, children = []) => {
    const node = document.createElement(tag);
    for (const [name, value] of Object.entries(attrs)) {
      if (name === "class") node.className = value;
      else if (name === "text") node.textContent = value;
      else if (name === "html") node.innerHTML = value;
      else node.setAttribute(name, value);
    }
    for (const child of [].concat(children)) node.appendChild(child);
    return node;
  };

  const randomHex = (bytes) =>
    Array.from(crypto.getRandomValues(new Uint8Array(bytes)), (b) => b.toString(16).padStart(2, "0")).join("");
  window.randomHex = randomHex;


  const spec = window.DROPIN_SPEC;
  let repeatUid = 0;
  const form = document.querySelector("#scenario-form");
  const cards = document.querySelector("#scenarios");
  const result = document.querySelector("#result");
  const dropinOutput = document.querySelector("#dropin-output");
  const envOutput = document.querySelector("#env-output");
  const commandsOutput = document.querySelector("#commands-output");
  const envCard = document.querySelector("#env-card");
  const filesCard = document.querySelector("#files-card");
  const errors = document.querySelector("#errors");
  const downloadDropin = document.querySelector("#download-dropin");
  const downloadEnv = document.querySelector("#download-env");
  const scenarioState = new Map();

  const fieldInput = (scenario, field, groupInputs) => {
    const id = `${scenario.id}-${field.key}`;
    if (field.showIf) {
      const holder = el("div");
      holder.dataset.holder = "1";
      const inner = fieldInput(scenario, { ...field, showIf: undefined }, groupInputs);
      holder.appendChild(inner.wrap);
      return { wrap: holder, input: inner.input };
    }
    const label = el("label", { for: id, text: field.label });
    let input;
    if (field.type === "select") {
      input = el("select", { id, name: id });
      for (const option of field.options) {
        input.appendChild(el("option", { value: option.value, text: option.label }));
      }
    } else if (field.type === "check") {
      const wrap = el("label", { class: "toggle-control" });
      input = el("input", { id, name: id, type: "checkbox", role: "switch" });
      wrap.appendChild(input);
      wrap.appendChild(el("span", { text: field.label }));
      if (field.hint) wrap.appendChild(el("span", { class: "hint", text: field.hint }));
      input.addEventListener("change", refresh);
      return { wrap, input };
    } else {
      input = el("input", {
        id,
        name: id,
        type: field.type === "secret" ? "password" : field.type || "text",
        autocomplete: "off",
        spellcheck: "false",
        placeholder: field.placeholder || "",
      });
      if (field.value) input.value = field.value;
      if (field.min) input.setAttribute("min", field.min);
      if (field.max) input.setAttribute("max", field.max);
      if (field.pattern) {
        input.setAttribute("pattern", field.pattern);
        input.setAttribute("title", field.patternMessage || "Check the format of this value.");
      }
    }
    input.addEventListener("input", () => {
      delete input.dataset.auto;
      refresh();
    });
    input.addEventListener("change", () => {
      refresh();
      if (field.prefill) field.prefill(input.value, (key, value) => {
        const target = groupInputs && groupInputs[key];
        if (target && (target.input.value === "" || target.input.value === target.input.dataset.auto)) {
          target.input.value = value;
          target.input.dataset.auto = value;
        }
      }, (key) => {
        const target = groupInputs && groupInputs[key];
        return target ? target.input.value : "";
      });
    });
    const wrap = el("div", {}, [label]);
    wrap.appendChild(input);
    if (field.hint && field.type !== "check") wrap.appendChild(el("p", { class: "hint", text: field.hint }));
    if (field.generate) {
      const button = el("button", { type: "button", text: field.generateLabel || "Generate a value" });
      button.style.marginTop = "0.5rem";
      button.addEventListener("click", () => {
        input.type = "text";
        input.value = field.generate();
        refresh();
      });
      wrap.appendChild(button);
    }
    return { wrap, input };
  };

  const renderScenario = (scenario) => {
    const card = el("section", { class: "card scenario" });
    const toggleId = `${scenario.id}-enabled`;
    const toggle = el("input", { id: toggleId, type: "checkbox", role: "switch" });
    toggle.addEventListener("change", () => {
      groupsWrap.hidden = !toggle.checked;
      refresh();
    });
    const toggleLabel = el("label", { class: "toggle-control", for: toggleId });
    toggleLabel.appendChild(toggle);
    toggleLabel.appendChild(el("span", { text: scenario.title }));
    card.appendChild(toggleLabel);
    if (scenario.description) card.appendChild(el("p", { class: "hint", html: scenario.description }));
    const groupsWrap = el("div", { hidden: true });
    const groupList = el("div");
    const state = { toggle, scenario, groups: [], repeat: !!scenario.repeat };

    const makeGroup = () => {
      const uid = `${scenario.id}-g${repeatUid++}`;
      const groupWrap = el("div", { class: "repeat-group" });
      const header = el("div", { class: "repeat-header" });
      const title = el("span", { class: "repeat-title" });
      header.appendChild(title);
      const remove = el("button", { type: "button", class: "repeat-remove", text: "Remove" });
      remove.addEventListener("click", () => {
        state.groups = state.groups.filter((g) => g !== group);
        groupWrap.remove();
        relabel();
        refresh();
      });
      header.appendChild(remove);
      groupWrap.appendChild(header);
      const inputs = {};
      for (const field of scenario.fields || []) {
        const scoped = { ...field, key: `${field.key}__${uid}` };
        const { wrap, input } = fieldInput({ id: scenario.id }, scoped, inputs);
        inputs[field.key] = { input, field: scoped, holder: wrap.dataset.holder ? wrap : null };
        groupWrap.appendChild(wrap);
      }
      groupList.appendChild(groupWrap);
      const group = { uid, wrap: groupWrap, inputs, title, remove };
      state.groups.push(group);
      return group;
    };

    const relabel = () => {
      state.groups.forEach((group, i) => {
        group.title.textContent = (scenario.itemLabel || "Entry") + ` ${i + 1}`;
        group.remove.hidden = state.groups.length < 2;
      });
    };

    let inputs = {};
    if (state.repeat) {
      const add = el("button", { type: "button", class: "repeat-add", text: scenario.addLabel || "Add another" });
      add.addEventListener("click", () => { makeGroup(); relabel(); refresh(); });
      groupsWrap.appendChild(groupList);
      groupsWrap.appendChild(add);
      makeGroup();
      relabel();
    } else {
      for (const field of scenario.fields || []) {
        const { wrap, input } = fieldInput(scenario, field);
        inputs[field.key] = { input, field, holder: wrap.dataset.holder ? wrap : null };
        groupsWrap.appendChild(wrap);
      }
      state.groups.push({ uid: null, wrap: groupsWrap, inputs });
    }
    card.appendChild(groupsWrap);
    scenarioState.set(scenario.id, state);
    return card;
  };

  const groupValues = (group) => {
    const values = {};
    for (const [key, control] of Object.entries(group.inputs)) {
      values[key] = control.input.type === "checkbox" ? control.input.checked : control.input.value.trim();
    }
    return values;
  };

  const matchesShowIf = (values, showIf) => {
    if (typeof showIf === "function") return showIf(values);
    const value = values[showIf.key];
    const allowed = [].concat(showIf.equals);
    return allowed.includes(value);
  };

  const updateVisibility = () => {
    for (const state of scenarioState.values()) {
      for (const group of state.groups) {
        const values = groupValues(group);
        for (const { holder, field } of Object.values(group.inputs)) {
          if (holder) holder.hidden = !matchesShowIf(values, field.showIf);
        }
      }
    }
  };

  const validateGroup = (group) => {
    const problems = [];
    const values = groupValues(group);
    for (const { input, field, holder } of Object.values(group.inputs)) {
      if (holder && holder.hidden) continue;
      const value = input.type === "checkbox" ? input.checked : input.value.trim();
      if (field.required !== false && field.type !== "select" && value === "") {
        problems.push(`Enter a value for "${field.label}".`);
      } else if (field.pattern && value !== "" && !new RegExp(`^(?:${field.pattern})$`).test(value)) {
        problems.push(field.patternMessage || `"${field.label}" has an unexpected format.`);
      }
    }
    return { problems, values };
  };

  const assemble = () => {
    const containerLines = [];
    const serviceLines = [];
    const envLines = [];
    const extraFiles = [];
    const problems = [];
    for (const state of scenarioState.values()) {
      if (!state.toggle.checked) continue;
      const groupResults = [];
      let scenarioProblems = [];
      for (const group of state.groups) {
        const { problems: fieldProblems, values } = validateGroup(group);
        scenarioProblems = scenarioProblems.concat(fieldProblems);
        groupResults.push({ values, ok: fieldProblems.length === 0 });
      }
      if (scenarioProblems.length === 0) {
        if (state.scenario.validate) {
          const custom = state.scenario.validate(state.repeat ? groupResults.map((g) => g.values) : groupResults[0].values);
          scenarioProblems = scenarioProblems.concat(custom);
        }
      }
      if (scenarioProblems.length) {
        problems.push(...scenarioProblems);
        continue;
      }
      const run = (values) => {
        const sub = (line) => line.replace(/\$\{(\w+)\}/g, (_, key) => values[key] !== undefined ? values[key] : `\${${key}}`);
        const built = state.scenario.build(values);
        containerLines.push(...(built.container || []).map(sub));
        serviceLines.push(...(built.service || []).map(sub));
        envLines.push(...(built.env || []).map(sub));
        extraFiles.push(...(built.files || []).map((file) => ({ ...file, content: file.content.map(sub).join("\n") + "\n" })));
      };
      if (state.repeat) groupResults.forEach((g) => run(g.values));
      else run(groupResults[0].values);
    }
    return { containerLines, serviceLines, envLines, extraFiles, problems };
  };

  const renderCommands = (hasEnv, extraFiles) => {
    const deployRoot = `/mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0`;
    const lines = [
      "sudo mkdir -p /mnt/newroot",
      "sudo mount /dev/REPLACE_WITH_ROOT_PARTITION /mnt/newroot",
      `sudo install -D -m 0644 ~/20-custom.conf \\`,
      `  ${deployRoot}/etc/containers/systemd/${spec.unit}.container.d/20-custom.conf`,
    ];
    for (const file of extraFiles) {
      lines.push(`sudo install -D -m 0644 ~/${file.name} \\`);
      lines.push(`  ${deployRoot}/etc/containers/systemd/${file.name}`);
    }
    if (hasEnv) {
      lines.push(`# Only because a scenario above stores a secret in an env file:`);
      lines.push(`sudo install -D -m 0600 ~/${spec.envFile.localName} \\`);
      lines.push(`  ${deployRoot}${spec.envFile.path}`);
    }
    lines.push("sudo umount /mnt/newroot");
    return lines.join("\n");
  };

  const makeBlobLink = (link, text, filename) => {
    if (link.dataset.url) URL.revokeObjectURL(link.dataset.url);
    const url = URL.createObjectURL(new Blob([text], { type: "text/plain" }));
    link.dataset.url = url;
    link.href = url;
    link.download = filename;
  };

  const refresh = () => {
    updateVisibility();
    const { containerLines, serviceLines, envLines, extraFiles, problems } = assemble();
    errors.hidden = problems.length === 0;
    errors.textContent = problems.join(" ");
    if (problems.length) {
      result.hidden = true;
      return;
    }
    const anyScenario = [...scenarioState.values()].some((state) => state.toggle.checked);
    result.hidden = !anyScenario;
    if (!anyScenario) return;
    const dropin = ["# 20-custom.conf"];
    if (containerLines.length) dropin.push("[Container]", ...containerLines);
    if (serviceLines.length) {
      if (dropin.length) dropin.push("");
      dropin.push("[Service]", ...serviceLines);
    }
    const dropinText = dropin.join("\n") + "\n";
    const envText = envLines.length ? envLines.join("\n") + "\n" : "";
    dropinOutput.value = dropinText;
    envCard.hidden = envLines.length === 0;
    envOutput.value = envText;
    commandsOutput.textContent = renderCommands(envLines.length > 0, extraFiles);
    downloadEnv.hidden = envLines.length === 0;
    makeBlobLink(downloadDropin, dropinText, "20-custom.conf");
    if (envLines.length) makeBlobLink(downloadEnv, envText, spec.envFile.localName);
    filesCard?.replaceChildren();
    if (!filesCard) return;
    filesCard.hidden = extraFiles.length === 0;
    for (const file of extraFiles) {
      filesCard.appendChild(el("label", { text: file.name }));
      const box = el("textarea", { readonly: "", spellcheck: "false" });
      box.value = file.content;
      filesCard.appendChild(box);
      const link = el("a", { class: "button", text: `Download ${file.name}` });
      makeBlobLink(link, file.content, file.name);
      filesCard.appendChild(link);
    }
  };

  window.buildDropinPage = () => {
    document.title = spec.title;
    document.querySelector("h1").textContent = spec.title;
    document.querySelector("#intro").innerHTML = spec.intro;
    for (const scenario of spec.scenarios) cards.appendChild(renderScenario(scenario));
    document.querySelector("#generate").addEventListener("click", refresh);
    const copyTargets = [
      ["copy-dropin", () => dropinOutput.value],
      ["copy-env", () => envOutput.value],
      ["copy-commands", () => commandsOutput.textContent],
    ];
    for (const [id, get] of copyTargets) {
      const node = document.getElementById(id);
      if (node) node.addEventListener("click", () => navigator.clipboard.writeText(get()));
    }
  };
})();
