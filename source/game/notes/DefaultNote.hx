package game.notes;

class DefaultNote extends Note {
    public override function create() {
        this.loadFrames('game/notes/default');

        animation.rename(["purpleScroll", "blueScroll", "greenScroll", "redScroll"][strumID], "scroll");
        animation.rename(["purpleholdend", "blueholdend", "greenholdend", "redholdend"][strumID], "holdend");
        animation.rename(["purplehold", "bluehold", "greenhold", "redhold"][strumID], "hold");

        scale.set(0.7, 0.7);

        antialiasing = true;
        updateHitbox();
    }
}