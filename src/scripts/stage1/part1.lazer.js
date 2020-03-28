import { droneWave } from "./enemies/drones.lazer";
import { playerShip } from "../playerShip.lazer";
import { bigText } from "src/components/BigText";
import { playAudio } from "src/lib/audio";
import { say } from "src/lib/Dialog";

const stage1 = async ({
  setScrollingSpeed,
  setScenery,
  setAltitude,
  loadSpriteSheets,
  loadAudio,
  setBackground,
  setBackgroundCheckpointLimit,
  playAnimation,
  showHUD,
  exec,
  wait
}) => {
  const text = bigText("Loading...");
  text.fadeIn(2000);

  await loadSpriteSheets(["mega-texture"]);
  await loadAudio(["laser-shot", "laser-hit", "explosion", "hero"]);
  playAudio("hero");

  await setScrollingSpeed(100, 0);
  await setScenery("City.Ocean");
  setBackground("City.Sunrise");
  text.remove();
  const introAnimation = playAnimation("City.Intro");
  await Promise.all([
    introAnimation.waitTillCheckpoint(3),
    (async () => {
      await wait(1000);
      await say(
        "General",
        "Let us escort you to the factory to install\n" +
          "the AI controlled defence systems. You are the last ship.",
        { portrait: "portraits.general" }
      );
    })()
  ]);
  showHUD();
  const ready = bigText("Get ready", { color: "#FF0000" });
  const blink = ready.blink(200, 4);

  exec(playerShip({ existing: true }));
  setBackgroundCheckpointLimit(4);

  await setScrollingSpeed(250, 0);
  const droneAttacks = async () => {
    await blink;
    await ready.zoomOut(500);
    ready.remove();
    await say(
      "General",
      "We send some drones for some last manual target practice",
      { portrait: "portraits.general" }
    );
    await say("John", "Let's go!", { portrait: "portraits.pilot" });
    await exec(droneWave(5, "pattern1", 500));
    await exec(droneWave(8, "pattern2", 500));
  };
  const flyHeight = async () => {
    await introAnimation.waitTillEnd();
    await setAltitude(200);
  };
  await Promise.all([flyHeight(), droneAttacks()]);
  introAnimation.destroy();
  await setAltitude(0);
  await exec(droneWave(5, "pattern1", 500));
};

export default stage1;
