package ru.actors.ui;

import com.ericsson.otp.erlang.*;
import lombok.extern.log4j.Log4j2;

import javax.swing.*;

@Log4j2
public class ReceiveRunnable implements Runnable {

    private final OtpMbox jProcess;
    private final JTextArea textArea;

    public ReceiveRunnable(OtpMbox jProcess, JTextArea textArea) {
        this.jProcess = jProcess;
        this.textArea = textArea;
    }

    @Override
    public void run() {
        try {
            OtpErlangObject response = jProcess.receive();
            String responseString;
            if (response instanceof OtpErlangTuple) {
                OtpErlangPid from = (OtpErlangPid) ((OtpErlangTuple) response).elementAt(0);
                OtpErlangObject body = ((OtpErlangTuple) response).elementAt(1);
                responseString = String.format("Получено от: %s. Body: %s", from.toString(), body);
            } else if (response instanceof OtpErlangString) {
                responseString = ((OtpErlangString) response).stringValue();
            } else
                responseString = response != null ? response.toString() : null;
            if (responseString != null) {
                log.info("Receive message: {}", responseString);
                textArea.append(responseString + '\n');
            }
        } catch (Exception e) {
            log.error("error to receive msg", e);
        }
    }
}
