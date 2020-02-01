with HWIF; use HWIF;
with HWIF_Types; use HWIF_Types;
with Ada.Calendar; use Ada.Calendar;

procedure Controller is

   Times : constant array (Integer range 1..16) of
   Duration := (0.2, 0.2, 5.0, 3.0, 0.2, 5.0, 3.0, 0.2, 0.41, 5.0, 3.0, 0.2, 0.2, 5.0, 3.0, 6.0); --The Times of duration for each State
   State : Integer := 1; --Start at state one
   FrameDelay : constant Duration := 0.2; --Duration to represent the length of interval "FrameDelay"
   TimeNext : Time := Ada.Calendar.Clock; -- Declaring TimeNext which is of type time
   TimeNextState : Time := Ada.Calendar.Clock; -- Declaring TimeNextState which is of type time

   -- 1 ALL_RED
   -- 2 EV_NS_RA
   -- 3 EV_NS_G
   -- 4 EV_NS_A
   -- 5 EV_EW_RA
   -- 6 EV_EW_G
   -- 7 EV_EW_A
   -- 8 All-RED-BEFORE_NS
   -- 9 NS_RED_AMBER
   -- 10 NS_GREEN
   -- 11 NS_AMBER
   -- 12 All-RED-BEFORE_EW
   -- 13 EW_RED_AMBER
   -- 14 EW_GREEN
   -- 15 EW_AMBER
   -- 16 PEDESTRIAN_GREEN

begin
   loop -- begin forever loop

      --This block contains code to ensure that if a button is pressed then the corresponding wait light must come on.
      if Pedestrian_Button(North) = 1 then Pedestrian_Wait(North) := 1;end if;
      if Pedestrian_Button(South) = 1 then Pedestrian_Wait(South) := 1;end if;
      if Pedestrian_Button(East) = 1 then Pedestrian_Wait(East) := 1;end if;
      if  Pedestrian_Button(West) = 1 then Pedestrian_Wait(West) := 1; end if;

      --This block contains code to ensure that if the state is 16 then all Pedestrian Wait lights must not show, this acts as a reset.
      if State = 16 then Pedestrian_Wait(North) := 0; end if;
      if State = 16 then Pedestrian_Wait(South) := 0; end if;
      if State = 16 then Pedestrian_Wait(East) := 0; end if;
      if State = 16 then Pedestrian_Wait(West) := 0; end if;

      --This block checks that the sensor is on and if the state is EV green,  if both paramaters are true then add 10 seconds
      if Emergency_Vehicle_Sensor(North) = 1 and State = 3 then TimeNextState := Ada.Calendar.Clock + 10.0;
      elsif Emergency_Vehicle_Sensor(South) = 1 and State = 3 then TimeNextState := Ada.Calendar.Clock + 10.0;
      elsif Emergency_Vehicle_Sensor(East) = 1 and State = 6 then TimeNextState := Ada.Calendar.Clock + 10.0;
      elsif Emergency_Vehicle_Sensor(West) = 1 and State = 6 then TimeNextState := Ada.Calendar.Clock + 10.0;
      end if;


      if Ada.Calendar.">="(Ada.Calendar.Clock, TimeNextState) then  -- This if statement is used to manipulate the Case statements

         case State is --All Case statements (1-16) (ManipulationState)
         when 1 => --ALL_RED

            --Statement block to say that if the EV_Sensor is active then display the relevant state
            if Emergency_Vehicle_Sensor(North) = 1 then State := 2;
            elsif Emergency_Vehicle_Sensor(South) = 1 then State := 2;
            elsif Emergency_Vehicle_Sensor(East) = 1 then State := 5;
            elsif Emergency_Vehicle_Sensor(West) = 1 then State := 5;
            else State := 9; end if;

         When 2 => --EmergencyVehicle_North/South_RED/AMBER
            State := 3;

         When 3 => --EmergencyVehicle_North/South_GREEN
            State := 4;

         When 4 => --EmergencyVehicle_North/South_Amber
            State := 12; --when N/S EV has complete go to regular East/West Lights

         When 5 => --EmergencyVehicle_East/West_RED/AMBER
            State := 6;

         When 6 => --EmergencyVehicle_East/West_GREEN
            State := 7;

         When 7 => --EmergencyVehicle_East/West_Amber
            State := 8; --when E/W EV has complete go to regular North/South Lights

         when 8 => -- All RED_NS
            if Emergency_Vehicle_Sensor(East) = 1 then State := 5;
            elsif Emergency_Vehicle_Sensor(West) = 1 then State := 5;
            end if;

            State := 9;

         when 9 => -- N-S_RED/AMBER
            State := 10;

         when 10 => --N-S_GREEN
           State := 11;

         when 11 => --N-S_AMBER

            if Emergency_Vehicle_Sensor(North) = 1 then State := 1;
            elsif Emergency_Vehicle_Sensor(South) = 1 then State := 1;
            else State := 13; end if;

         when 12 => -- All RED_EW
            if Emergency_Vehicle_Sensor(North) = 1 then State := 1;
            elsif Emergency_Vehicle_Sensor(South) = 1 then State := 1;
            end if;

            State := 13;

         when 13 => --E-W_RED/AMBER
            State := 14;

         when 14 => --E-W_GREEN
            State := 15;

         when 15 => --E-W_AMBER

            if Emergency_Vehicle_Sensor(East) = 1 then State := 1;
            elsif Emergency_Vehicle_Sensor(West) = 1 then State := 1;
            elsif Pedestrian_Wait(North) = 1 or else Pedestrian_Wait(South) = 1
            or else Pedestrian_Wait(East) = 1 or else Pedestrian_Wait(West) = 1 then State := 16;
            else State := 1; end if;

         when 16 => --PEDESTRIAN_GREEN
            State := 1;

         when others =>
            State := 1;
         end case;

         TimeNextState := Ada.Calendar.Clock + Times(State);

      end if;

      TimeNext := TimeNext + FrameDelay; --TimeNext is TimeNext plus 0.19
      if TimeNextState < TimeNext --if TimeNextState is less than TimeNext then display which ever is less
      then TimeNext := TimeNextState;
      end if;
      delay until TimeNext; --Delay until NextTime

      case State is --All Case statements (1-16)
         when 1 => --ALL_RED
            Traffic_Light(North) := 4;
            Traffic_Light(South) := 4;
            Traffic_Light(East) := 4;
            Traffic_Light(West) := 4;
            Pedestrian_Light(North) := 2;
            Pedestrian_Light(South) := 2;
            Pedestrian_Light(East) := 2;
            Pedestrian_Light(West) := 2;

         When 2 => --EmergencyVehicle_North/South_RED/AMBER
            Traffic_Light(North) := 6;
            Traffic_Light(South) := 6;

         When 3 => --EmergencyVehicle_North/South_GREEN_Extended
            Traffic_Light(North) := 1;
            Traffic_Light(South) := 1;

         When 4 => --EmergencyVehicle_North_Amber
            Traffic_Light(North) := 2;
            Traffic_Light(South) := 2;

         When 5 => --EmergencyVehicle_East/West_RED/AMBER
            Traffic_Light(East) := 6;
            Traffic_Light(West) := 6;

         When 6 => --EmergencyVehicle_East/Westh_GREEN_Extended
            Traffic_Light(East) := 1;
            Traffic_Light(West) := 1;

         When 7 => --EmergencyVehicle_East/West_Amber
            Traffic_Light(East) := 2;
            Traffic_Light(West) := 2;

         When 8 => --ALL RED Before N/S Lights
            Traffic_Light(North) := 4;
            Traffic_Light(South) := 4;
            Traffic_Light(East) := 4;
            Traffic_Light(West) := 4;
            Pedestrian_Light(North) := 2;
            Pedestrian_Light(South) := 2;
            Pedestrian_Light(East) := 2;
            Pedestrian_Light(West) := 2;

         When 9 => -- N-S_RED/AMBER
            Traffic_Light(North) := 6;
            Traffic_Light(South) := 6;
            Traffic_Light(East) := 4;
            Traffic_Light(West) := 4;

         when 10 => --N-S_GREEN
            Traffic_Light(North) := 1;
            Traffic_Light(South) := 1;

         when 11 => --N-S_AMBER
            Traffic_Light(North) := 2;
            Traffic_Light(South) := 2;

         When 12 => --ALL RED Before E/W Lights
            Traffic_Light(North) := 4;
            Traffic_Light(South) := 4;
            Traffic_Light(East) := 4;
            Traffic_Light(West) := 4;
            Pedestrian_Light(North) := 2;
            Pedestrian_Light(South) := 2;
            Pedestrian_Light(East) := 2;
            Pedestrian_Light(West) := 2;

         when 13 => --E-W_RED/AMBER
            Traffic_Light(East) := 6;
            Traffic_Light(West) := 6;
            Traffic_Light(North) := 4;
            Traffic_Light(South) := 4;

         when 14 => --E-W_GREEN
            Traffic_Light(East) := 1;
            Traffic_Light(West) := 1;

         when 15 => --E-W_AMBER
            Traffic_Light(East) := 2;
            Traffic_Light(West) := 2;

         When 16 => --PEDESTRIAN_GREEN
            Pedestrian_Light(North) := 1;
            Pedestrian_Light(South) := 1;
            Pedestrian_Light(East) := 1;
            Pedestrian_Light(West) := 1;
	    Traffic_Light(North) := 4;
            Traffic_Light(South) := 4;
            Traffic_Light(East) := 4;
            Traffic_Light(West) := 4;

        when others =>
          null;
      end case;
   end loop;
end Controller;
