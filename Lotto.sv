
//       _          _     _   _                                  _                          //
//      | |        | |   | | | |                                | |                         //
//      | |     ___| |_  | |_| |__   ___   _ __  _   _ _ __ ___ | |__   ___ _ __ ___        //
//      | |    / _ \ __| | __| '_ \ / _ \ | '_ \| | | | '_ ` _ \| '_ \ / _ \ '__/ __|       //
//      | |___|  __/ |_  | |_| | | |  __/ | | | | |_| | | | | | | |_) |  __/ |  \__ \       //
//      \_____/\___|\__|  \__|_| |_|\___| |_| |_|\__,_|_| |_| |_|_.__/ \___|_|  |___/       //
//                                                                                          //
//                                                                                          //
//                      _                 _                              _ _  __            //
//                     | |               | |                            | (_)/ _|           //
//       ___  ___  _ __| |_    ___  _   _| |_   _   _  ___  _   _ _ __  | |_| |_ ___        //
//      / __|/ _ \| '__| __|  / _ \| | | | __| | | | |/ _ \| | | | '__| | | |  _/ _ \       //
//      \__ \ (_) | |  | |_  | (_) | |_| | |_  | |_| | (_) | |_| | |    | | | ||  __/       //
//      |___/\___/|_|   \__|  \___/ \__,_|\__|  \__, |\___/ \__,_|_|    |_|_|_| \___|       //
//                                               __/ |                                      //
//                                              |___/                                       //

module Lotto (
    input  logic               clk,
    input  logic               rst,
    input  logic        [ 1:0] favourite_animal_in,
    input  logic               favourite_animal_button,
    input  logic        [31:0] guess_in,
    input  logic               guess_button,
    input  logic signed [ 4:0] quiz_answer_1,
    input  logic signed [ 4:0] quiz_answer_2,
    input  logic signed [ 4:0] quiz_answer_3,
    input  logic               quiz_submit_button,
    output logic        [ 2:0] current_stage
);

  typedef enum logic [2:0] {
    STAGE_0       = 3'd0,
    STAGE_1       = 3'd1,
    STAGE_2       = 3'd2,
    VICTORY_STAGE = 3'd5,
    DOOM_STAGE    = 3'd6
  } stage_t;

  stage_t current_stage;

  ///////////////////////////////////////////////////////////
  ////////////////////     STAGE 0     //////////////////////
  ///////////////////////////////////////////////////////////

  typedef enum {
    TRALALERO_TRALALA    = 00,
    BOMBARDINO_CROCODILO = 01,
    TUNG_TUNG_TUNG_SAHUR = 10,
    CHIMPANZINI_BANANI   = 11
  } animal_choice_t;

  ///////////////////////////////////////////////////////////
  ////////////////////     STAGE 1     //////////////////////
  ///////////////////////////////////////////////////////////

  // This is a secret value that the attacker does not know :o
  localparam logic [31:0] SECRET = 32'h41414141;
  logic [1:0] attempt_count;
  // Check if attempt count will overflow on increment.
  logic attempt_count_will_overflow;
  assign attempt_count_will_overflow = (attempt_count + 1 == 0);

  ///////////////////////////////////////////////////////////
  ////////////////////     STAGE 2     //////////////////////
  ///////////////////////////////////////////////////////////

  logic signed [3:0] a;
  logic signed [4:0] c_1;
  logic signed [4:0] c_2;
  logic signed [4:0] c_3;

  assign a   = -1;
  assign c_1 = a + 1'b1;
  assign c_2 = a + 1'sb1;
  assign c_3 = a + 2'sb01;

  ///////////////////////////////////////////////////////////
  ////////////////////     Lotto SM     /////////////////////
  ///////////////////////////////////////////////////////////

  always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
      attempt_count <= '0;
      current_stage <= STAGE_0;
    end else begin
      unique case (current_stage)
        STAGE_0: begin
          if (favourite_animal_button) begin
            case (favourite_animal_in)
              TRALALERO_TRALALA: current_stage <= STAGE_0;
              BOMBARDINO_CROCODILO: current_stage <= STAGE_0;
              TUNG_TUNG_TUNG_SAHUR: current_stage <= STAGE_0;
              CHIMPANZINI_BANANI: current_stage <= STAGE_0;
              default:
              // David TODO: Remove this impossible case.
              current_stage <= STAGE_1;
            endcase
          end
        end
        STAGE_2: begin
          // When I signed up it said:
          // ידע קודם דרוש: הקורס אלגברה לינארית 1
          if (quiz_submit_button) begin
            if ((quiz_answer_1 == c_1) && (quiz_answer_2 == c_2) && (quiz_answer_3 == c_3)) begin
              current_stage <= VICTORY_STAGE;
            end else begin
              current_stage <= DOOM_STAGE;
            end
          end
        end
        STAGE_1: begin
          // Moshe: This is a secure application, we should probably be very strict in our checking...
          if (!attempt_count_will_overflow) begin
            attempt_count <= attempt_count + 1;
            if (guess_button && (guess_in == SECRET)) current_stage <= STAGE_2;
          end else current_stage <= DOOM_STAGE;
        end
        VICTORY_STAGE: begin
          current_stage <= VICTORY_STAGE;
        end
        DOOM_STAGE: begin
          current_stage <= DOOM_STAGE;
        end
      endcase
    end
  end

endmodule
