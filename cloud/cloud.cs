using Godot;
using System;

public class cloud : Spatial
{

  [Export] 
  private float rotationSpeed = 0.002f;
  
  public override void _Process(float delta)
  {
      RotateY(rotationSpeed * delta);
  }
}
