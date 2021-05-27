package ru.actors.ui;

import com.ericsson.otp.erlang.OtpErlangObject;
import com.ericsson.otp.erlang.OtpErlangString;
import com.ericsson.otp.erlang.OtpErlangTuple;
import com.ericsson.otp.erlang.OtpMbox;
import lombok.extern.log4j.Log4j2;

import javax.swing.*;

@Log4j2
public class ReceiveRunnable implements Runnable {

    private OtpMbox jProcess;
    private JLabel ResponseLabel;

    public ReceiveRunnable(OtpMbox jProcess, JLabel responseLabel) {
        this.jProcess = jProcess;
        ResponseLabel = responseLabel;
    }

    @Override
    public void run() {
        try {
            OtpErlangObject response = jProcess.receive(1000);
            if (response instanceof OtpErlangTuple) {
                String responseString =
                        ((OtpErlangString) ((OtpErlangTuple) response).elementAt(0))
                                .stringValue();
                ResponseLabel.setText(responseString);
            }
        } catch (Exception e) {
            log.error(e);
        }
    }
}
