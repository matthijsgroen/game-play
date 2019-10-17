import styles from "./Menu.scss";
import { Link } from "preact-router/match";
import { h } from "preact";

const classes = def =>
  Object.entries(def)
    .filter(([, active]) => active)
    .map(([name]) => name)
    .join(" ");

const isFolder = name => f => f.type === "folder" && f.name === name;

const makeFolders = (acc, [name, path]) => {
  if (name.includes(".")) {
    const [folder, ...itemName] = name.split(".");
    const existingFolder = acc.find(isFolder(folder));
    if (!existingFolder) {
      return acc.concat({
        name: folder,
        type: "folder",
        items: [[itemName.join("."), path]]
      });
    }
    return acc.map(e =>
      isFolder(folder)(e)
        ? { ...e, items: e.items.concat([[itemName.join("."), path]]) }
        : e
    );
  }
  return acc.concat({ name, path, type: "item" });
};

const Item = ({ name, path }) => (
  <li class={styles.item}>
    {path ? (
      <Link activeClassName={styles.active} href={path}>
        {name}
      </Link>
    ) : (
      name
    )}
  </li>
);

const Folder = ({ name, items }) => (
  <li class={styles.folder}>
    <span class={styles.folderName}>{name}</span>
    <ul>{createStructure(items.reduce(makeFolders, []))}</ul>
  </li>
);

const createStructure = items =>
  items
    .filter(({ type }) => type === "folder")
    .map(folder => (
      <Folder key={folder.name} name={folder.name} items={folder.items} />
    ))
    .concat(
      items
        .filter(({ type }) => type === "item")
        .map(item => (
          <Item
            key={item.path}
            name={item.name}
            path={item.path ? `/editor${item.path}` : null}
          />
        ))
    );

export const Menu = ({ items, horizontal }) => (
  <menu
    class={classes({ [styles.menu]: true, [styles.horizontal]: horizontal })}
  >
    {createStructure(items.reduce(makeFolders, []))}
  </menu>
);
