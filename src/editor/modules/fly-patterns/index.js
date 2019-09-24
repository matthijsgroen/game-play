import { h, Component } from "preact";
import { Title } from "../../components/Title";
import { Menu } from "../../components/Menu";
import { Divider } from "../../components/Divider";
import { Setting } from "../../components/Setting";
import FlyPatternPreview from "./components/FlyPatternPreview";
import flyPatterns from "src/data/fly-patterns";

const DEFAULT_STATE = {
  showPoints: true,
  showPath: true
};

const STORAGE_KEY = "editor-flyPattern-settings";
const storeState = newState =>
  localStorage.setItem(STORAGE_KEY, JSON.stringify(newState));

const storedState = () => {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
  } catch (e) {
    return {};
  }
};

class FlyPatterns extends Component {
  constructor(props) {
    super(props);
    this.state = {
      ...DEFAULT_STATE,
      ...storedState()
    };
  }

  updateShowPoints = checked => {
    this.setState(s => ({ ...s, showPoints: checked }));
  };

  updateShowPath = checked => {
    this.setState(s => ({ ...s, showPath: checked }));
  };

  render({ pattern }, { showPoints, showPath }) {
    const activePattern = flyPatterns[pattern];
    storeState(this.state);
    return (
      <section>
        <Title>Fly patterns</Title>
        <Divider>
          <Menu
            items={Object.keys(flyPatterns).map(key => [
              key,
              `/fly-patterns/${key}`
            ])}
          />
          <div>
            <div>
              <Setting checked={showPoints} onCheck={this.updateShowPoints}>
                Show points
              </Setting>
              <Setting checked={showPath} onCheck={this.updateShowPath}>
                Show path
              </Setting>
            </div>
            {activePattern && (
              <FlyPatternPreview
                pattern={activePattern}
                showPath={showPath}
                showPoints={showPoints}
              />
            )}
          </div>
        </Divider>
      </section>
    );
  }
}

export default FlyPatterns;
