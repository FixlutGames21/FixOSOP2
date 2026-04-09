const state = {
  windows: [],
  activeWindowId: null,
  zIndex: 20,
  nextWindowId: 1,
  currentPath: "C:/",
  browserAddress: "fixos://home",
  browserMode: "internal",
  theme: "Aero Blue"
};

const fileSystem = {
  "C:/": [
    { name: "Desktop", type: "folder", path: "C:/Desktop" },
    { name: "Documents", type: "folder", path: "C:/Documents" },
    { name: "Programs", type: "folder", path: "C:/Programs" },
    { name: "System", type: "folder", path: "C:/System" }
  ],
  "C:/Desktop": [
    { name: "Browser.lnk", type: "shortcut", action: "browser" },
    { name: "Settings.lnk", type: "shortcut", action: "settings" },
    { name: "Readme.txt", type: "text", content: "FixOS prototype for OpenComputers 2: Reimagine." }
  ],
  "C:/Documents": [
    { name: "Roadmap.txt", type: "text", content: "1. Desktop shell\n2. Explorer\n3. Start Menu\n4. Browser\n5. Installer" },
    { name: "Theme Notes.txt", type: "text", content: "Visual direction: Windows 8/10 with blue glass UI." }
  ],
  "C:/Programs": [
    { name: "Explorer.app", type: "app", action: "explorer" },
    { name: "Browser.app", type: "app", action: "browser" },
    { name: "Settings.app", type: "app", action: "settings" }
  ],
  "C:/System": [
    { name: "kernel.sys", type: "system", content: "FixOS visual kernel placeholder" },
    { name: "shell.dll", type: "system", content: "Shell runtime placeholder" }
  ]
};

const appMeta = {
  explorer: { title: "Проводник", icon: "📁" },
  browser: { title: "Браузер", icon: "🌐" },
  settings: { title: "Параметры", icon: "⚙" },
  about: { title: "О системе", icon: "🪟" }
};

const desktop = document.getElementById("desktop");
const windowLayer = document.getElementById("windowLayer");
const startMenu = document.getElementById("startMenu");
const contextMenu = document.getElementById("contextMenu");
const taskbarApps = document.getElementById("taskbarApps");
const startButton = document.getElementById("startButton");

function pad(value) {
  return String(value).padStart(2, "0");
}

function updateClock() {
  const now = new Date();
  document.getElementById("taskbarClock").textContent = `${pad(now.getHours())}:${pad(now.getMinutes())}`;
  document.getElementById("taskbarDate").textContent = `${pad(now.getDate())}.${pad(now.getMonth() + 1)}.${now.getFullYear()}`;
}

function toggleStartMenu(force) {
  const show = typeof force === "boolean" ? force : startMenu.classList.contains("hidden");
  startMenu.classList.toggle("hidden", !show);
}

function hideMenus() {
  toggleStartMenu(false);
  contextMenu.classList.add("hidden");
}

function bringToFront(windowId) {
  const target = state.windows.find((item) => item.id === windowId);
  if (!target) return;
  state.activeWindowId = windowId;
  state.zIndex += 1;
  target.element.style.zIndex = state.zIndex;
  renderTaskbar();
}

function renderTaskbar() {
  taskbarApps.innerHTML = "";
  state.windows.forEach((item) => {
    const button = document.createElement("button");
    button.className = `taskbar-app ${item.id === state.activeWindowId && !item.minimized ? "is-active" : ""}`;
    button.textContent = appMeta[item.type].icon;
    button.title = appMeta[item.type].title;
    button.addEventListener("click", () => {
      if (item.minimized) {
        item.minimized = false;
        item.element.classList.remove("hidden-window");
      }
      bringToFront(item.id);
    });
    taskbarApps.appendChild(button);
  });
}

function getWindowByType(type) {
  return state.windows.find((item) => item.type === type);
}

function createWindow(type) {
  const existing = getWindowByType(type);
  if (existing) {
    existing.minimized = false;
    existing.element.classList.remove("hidden-window");
    bringToFront(existing.id);
    return existing;
  }

  const tpl = document.getElementById("windowTemplate");
  const fragment = tpl.content.cloneNode(true);
  const element = fragment.querySelector(".window");
  const title = fragment.querySelector(".window__title");
  const content = fragment.querySelector(".window__content");
  const id = state.nextWindowId++;
  const meta = appMeta[type];

  title.textContent = `${meta.icon} ${meta.title}`;
  element.dataset.windowId = String(id);
  element.style.left = `${110 + state.windows.length * 26}px`;
  element.style.top = `${70 + state.windows.length * 24}px`;
  element.style.zIndex = String(++state.zIndex);

  content.appendChild(renderApp(type));
  windowLayer.appendChild(fragment);

  const windowElement = windowLayer.querySelector(`[data-window-id="${id}"]`);
  const record = { id, type, element: windowElement, minimized: false, maximized: false };
  state.windows.push(record);

  wireWindow(record);
  bringToFront(id);
  renderTaskbar();
  return record;
}

function wireWindow(record) {
  const titlebar = record.element.querySelector(".window__titlebar");
  const actionButtons = record.element.querySelectorAll(".window__action");

  record.element.addEventListener("mousedown", () => bringToFront(record.id));

  actionButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const action = button.dataset.action;
      if (action === "close") {
        record.element.remove();
        state.windows = state.windows.filter((item) => item.id !== record.id);
        if (state.activeWindowId === record.id) {
          const lastWindow = state.windows[state.windows.length - 1];
          state.activeWindowId = lastWindow ? lastWindow.id : null;
        }
        renderTaskbar();
      }
      if (action === "minimize") {
        record.minimized = true;
        record.element.classList.add("hidden-window");
        renderTaskbar();
      }
      if (action === "maximize") {
        record.maximized = !record.maximized;
        record.element.classList.toggle("is-maximized", record.maximized);
      }
    });
  });

  let dragging = false;
  let offsetX = 0;
  let offsetY = 0;

  titlebar.addEventListener("mousedown", (event) => {
    if (record.maximized) return;
    dragging = true;
    offsetX = event.clientX - record.element.offsetLeft;
    offsetY = event.clientY - record.element.offsetTop;
    bringToFront(record.id);
  });

  window.addEventListener("mousemove", (event) => {
    if (!dragging) return;
    record.element.style.left = `${Math.max(0, event.clientX - offsetX)}px`;
    record.element.style.top = `${Math.max(0, event.clientY - offsetY)}px`;
  });

  window.addEventListener("mouseup", () => {
    dragging = false;
  });
}

function renderApp(type) {
  if (type === "explorer") return renderExplorer();
  if (type === "browser") return renderBrowser();
  if (type === "settings") return renderSettings();
  return renderAbout();
}

function renderExplorer() {
  const wrapper = document.createElement("section");
  wrapper.className = "app-shell explorer";
  wrapper.innerHTML = `
    <aside class="sidebar">
      <h3>Разделы</h3>
      <div class="nav-list">
        <button data-path="C:/">Этот компьютер</button>
        <button data-path="C:/Desktop">Рабочий стол</button>
        <button data-path="C:/Documents">Документы</button>
        <button data-path="C:/Programs">Программы</button>
        <button data-path="C:/System">Система</button>
      </div>
    </aside>
    <div class="content-pane">
      <div class="toolbar">
        <input id="pathInput" value="${state.currentPath}">
        <button id="openPathButton">Открыть путь</button>
        <button id="newFolderButton">Новая папка</button>
      </div>
      <div class="path-label">Текущий путь: <span id="currentPathLabel">${state.currentPath}</span></div>
      <div class="file-list" id="fileList"></div>
    </div>
  `;

  setTimeout(() => {
    bindExplorer(wrapper);
    refreshExplorer(wrapper);
  });
  return wrapper;
}

function bindExplorer(wrapper) {
  wrapper.querySelectorAll("[data-path]").forEach((button) => {
    button.addEventListener("click", () => {
      state.currentPath = button.dataset.path;
      refreshExplorer(wrapper);
    });
  });

  wrapper.querySelector("#openPathButton").addEventListener("click", () => {
    const value = wrapper.querySelector("#pathInput").value.trim();
    state.currentPath = fileSystem[value] ? value : state.currentPath;
    refreshExplorer(wrapper);
  });

  wrapper.querySelector("#newFolderButton").addEventListener("click", () => {
    const folderName = `New Folder ${fileSystem[state.currentPath].length + 1}`;
    const newPath = `${state.currentPath.replace(/\/$/, "")}/${folderName}`;
    fileSystem[state.currentPath].push({ name: folderName, type: "folder", path: newPath });
    fileSystem[newPath] = [];
    refreshExplorer(wrapper);
  });
}

function refreshExplorer(wrapper) {
  const list = wrapper.querySelector("#fileList");
  const input = wrapper.querySelector("#pathInput");
  const label = wrapper.querySelector("#currentPathLabel");
  const entries = fileSystem[state.currentPath] || [];

  input.value = state.currentPath;
  label.textContent = state.currentPath;
  list.innerHTML = "";

  if (!entries.length) {
    const empty = document.createElement("div");
    empty.className = "empty-state";
    empty.textContent = "Папка пуста.";
    list.appendChild(empty);
    return;
  }

  entries.forEach((entry) => {
    const item = document.createElement("button");
    item.className = "file-item";
    item.innerHTML = `
      <span>${entry.type === "folder" ? "📁" : entry.type === "shortcut" || entry.type === "app" ? "🚀" : "📄"}</span>
      <span class="file-item__name">${entry.name}</span>
      <span class="file-item__meta">${entry.type}</span>
    `;

    item.addEventListener("dblclick", () => {
      if (entry.type === "folder" && entry.path) {
        state.currentPath = entry.path;
        refreshExplorer(wrapper);
      } else if (entry.action) {
        createWindow(entry.action);
      } else if (entry.content) {
        alert(entry.content);
      }
    });

    item.addEventListener("contextmenu", (event) => {
      event.preventDefault();
      showContextMenu(event.clientX, event.clientY, [
        { label: "Открыть", action: () => item.dispatchEvent(new MouseEvent("dblclick")) },
        { label: "Свойства", action: () => alert(`Имя: ${entry.name}\nТип: ${entry.type}`) }
      ]);
    });

    list.appendChild(item);
  });
}

function renderSettings() {
  const wrapper = document.createElement("section");
  wrapper.className = "app-shell settings";
  wrapper.innerHTML = `
    <div class="settings__hero">
      <h3>Параметры системы</h3>
      <p>Настройка внешнего вида FixOS, поведения оболочки и будущих программ.</p>
    </div>
    <div class="settings__grid">
      <div class="setting-card">
        <strong>Тема</strong>
        <div class="setting-list">
          <button data-theme="Aero Blue">Aero Blue</button>
          <button data-theme="Midnight">Midnight</button>
          <button data-theme="Emerald">Emerald</button>
        </div>
      </div>
      <div class="setting-card">
        <strong>Интерфейс</strong>
        <p>Стиль вдохновлён Windows 8/10: плитки, стекло, панель задач и окна.</p>
      </div>
      <div class="setting-card">
        <strong>Система</strong>
        <p>Версия прототипа: <code>0.1 Reimagine</code></p>
        <p>Текущая тема: <span id="themeValue">${state.theme}</span></p>
      </div>
      <div class="setting-card">
        <strong>Следующий этап</strong>
        <p>Перенос оболочки в формат, который уже сможет работать внутри OpenComputers 2.</p>
      </div>
    </div>
  `;

  setTimeout(() => {
    wrapper.querySelectorAll("[data-theme]").forEach((button) => {
      button.addEventListener("click", () => {
        state.theme = button.dataset.theme;
        wrapper.querySelector("#themeValue").textContent = state.theme;
      });
    });
  });
  return wrapper;
}

function internalPages(address) {
  const pages = {
    "fixos://home": `
      <h2>Добро пожаловать в FixOS Browser</h2>
      <p>Это стартовая страница браузера внутри прототипа системы.</p>
      <p>Можно открывать внутренние страницы и внешние сайты по адресу.</p>
    `,
    "fixos://docs": `
      <h2>Документация</h2>
      <p>FixOS задуман как ОС в духе Windows для OpenComputers 2: Reimagine.</p>
      <p>Базовые модули: shell, explorer, settings, browser, start menu.</p>
    `,
    "fixos://op2": `
      <h2>OpenComputers 2</h2>
      <p>Следующая версия может получить настоящую файловую систему и установку программ внутри мода.</p>
    `
  };
  return pages[address] || `<h2>Страница не найдена</h2><p>Адрес <code>${address}</code> отсутствует во внутреннем реестре страниц.</p>`;
}

function renderBrowser() {
  const wrapper = document.createElement("section");
  wrapper.className = "app-shell browser";
  wrapper.innerHTML = `
    <div class="browser__hero">
      <h3>FixOS Browser</h3>
      <p>Встроенный браузер для локальных страниц FixOS и внешних переходов.</p>
    </div>
    <div class="browser__toolbar">
      <button id="browserHome">⌂</button>
      <input id="browserAddress" value="${state.browserAddress}">
      <select id="browserMode">
        <option value="internal">Внутри окна</option>
        <option value="external">Во внешней вкладке</option>
      </select>
      <button id="browserGo">Перейти</button>
    </div>
    <div class="browser__layout">
      <div class="quick-links">
        <button data-address="fixos://home">Главная</button>
        <button data-address="fixos://docs">Документация</button>
        <button data-address="fixos://op2">OpenComputers 2</button>
        <button data-address="https://example.com">example.com</button>
      </div>
      <div class="browser__page" id="browserPage"></div>
    </div>
  `;

  setTimeout(() => {
    const addressInput = wrapper.querySelector("#browserAddress");
    const modeSelect = wrapper.querySelector("#browserMode");
    modeSelect.value = state.browserMode;

    const navigate = () => {
      state.browserAddress = addressInput.value.trim() || "fixos://home";
      state.browserMode = modeSelect.value;
      const page = wrapper.querySelector("#browserPage");

      if (state.browserMode === "external" && /^https?:\/\//.test(state.browserAddress)) {
        window.open(state.browserAddress, "_blank", "noopener");
        page.innerHTML = `<h2>Сайт открыт снаружи</h2><p>Адрес <code>${state.browserAddress}</code> отправлен во внешнюю вкладку браузера.</p>`;
        return;
      }

      if (/^https?:\/\//.test(state.browserAddress)) {
        page.innerHTML = `
          <h2>Внешний сайт</h2>
          <p>Некоторые сайты могут блокировать показ во <code>iframe</code>. Если так случится, переключи режим на внешний.</p>
          <iframe src="${state.browserAddress}" title="External page"></iframe>
        `;
        return;
      }

      page.innerHTML = internalPages(state.browserAddress);
    };

    wrapper.querySelector("#browserGo").addEventListener("click", navigate);
    wrapper.querySelector("#browserHome").addEventListener("click", () => {
      addressInput.value = "fixos://home";
      navigate();
    });
    wrapper.querySelectorAll("[data-address]").forEach((button) => {
      button.addEventListener("click", () => {
        addressInput.value = button.dataset.address;
        navigate();
      });
    });
    navigate();
  });

  return wrapper;
}

function renderAbout() {
  const wrapper = document.createElement("section");
  wrapper.className = "app-shell about";
  wrapper.innerHTML = `
    <div class="about__hero">
      <h3>FixOS Reimagine</h3>
      <p>Концепт системы для Minecraft-мода OpenComputers 2 с логикой Windows 8/10.</p>
    </div>
    <div class="about__body">
      <div class="about__card">
        <strong>Что уже реализовано</strong>
        <p>Рабочий стол, окна, Пуск, проводник, браузер, параметры и контекстные меню.</p>
      </div>
      <div class="about__card">
        <strong>Для чего это нужно</strong>
        <p>Сначала собрать интерфейс и UX, а затем переносить его в игровой модуль.</p>
      </div>
      <div class="about__card">
        <strong>Следующий шаг</strong>
        <p>Заменить демонстрационную файловую систему на реальную логику под OpenComputers 2 API.</p>
      </div>
    </div>
  `;
  return wrapper;
}

function showContextMenu(x, y, items) {
  contextMenu.innerHTML = "";
  items.forEach((item) => {
    const button = document.createElement("button");
    button.textContent = item.label;
    button.addEventListener("click", () => {
      hideMenus();
      item.action();
    });
    contextMenu.appendChild(button);
  });
  contextMenu.style.left = `${x}px`;
  contextMenu.style.top = `${y}px`;
  contextMenu.classList.remove("hidden");
}

function initDesktop() {
  updateClock();
  setInterval(updateClock, 1000);

  startButton.addEventListener("click", () => toggleStartMenu());

  document.querySelectorAll("[data-app]").forEach((button) => {
    button.addEventListener("click", () => {
      createWindow(button.dataset.app);
      hideMenus();
    });
  });

  desktop.addEventListener("contextmenu", (event) => {
    if (event.target.closest(".window") || event.target.closest(".desktop-icon")) return;
    event.preventDefault();
    showContextMenu(event.clientX, event.clientY, [
      { label: "Открыть Проводник", action: () => createWindow("explorer") },
      { label: "Открыть Браузер", action: () => createWindow("browser") },
      { label: "Параметры", action: () => createWindow("settings") },
      { label: "О системе", action: () => createWindow("about") }
    ]);
  });

  window.addEventListener("click", (event) => {
    if (!event.target.closest("#startMenu") && !event.target.closest("#startButton")) {
      toggleStartMenu(false);
    }
    if (!event.target.closest("#contextMenu")) {
      contextMenu.classList.add("hidden");
    }
  });

  createWindow("about");
}

initDesktop();
