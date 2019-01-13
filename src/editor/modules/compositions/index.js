import { CompositionPreview } from "./components/CompositionPreview";
import { Menu } from "../../components/Menu";
import { h } from "preact";
import compositions from "src/data/compositions";

const Compositions = ({ compositionName }) => {
  const activeComposition = compositions[compositionName];

  return (
    <section>
      <h1 style={{ color: "white" }}>Compositions</h1>
      <Menu
        items={Object.keys(compositions).map(key => [
          key,
          `/compositions/${key}`
        ])}
      />
      {activeComposition && (
        <CompositionPreview composition={activeComposition} />
      )}
    </section>
  );
};

export default Compositions;