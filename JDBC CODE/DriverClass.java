import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.*;
import java.util.Vector;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;

public class DriverClass {
	public static int index = 0;
	public static void main(String args[]){
		
		try {
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			}
			catch(ClassNotFoundException ex) {
			   System.out.println("Error: unable to load driver class!");
			   System.exit(1);
			  }
		
		String URL = "jdbc:sqlserver://occam.cs.qc.cuny.edu\\dbclass:21433;DatabaseName=AdventureWorksDW2016";
		String User = "student";
		String Password = "Remember1";
		String filename = "SQLQuery1.sql";
		String testquery = "";
		JFrame f = new JFrame();
		JButton left = new JButton("Previous Query");
		JButton right = new JButton("Next Query");
		f.setTitle("QUERY RESULTS");
		JPanel top,bLeft,bRight;
		
		try{
			Connection con = DriverManager.getConnection(URL,User,Password);
			System.out.println("Connection Secured!!!!");
			String queryCode = getSQLQuery();
			String queryAry[] = queryCode.split(";");
			PreparedStatement stmt = con.prepareStatement(queryAry[index]);
			System.out.println(queryAry[index]);
			ResultSet rs = stmt.executeQuery();

		    // It creates and displays the table
		    JTable table = new JTable(buildTableModel(rs));
		    table.setFillsViewportHeight(true);
		   
		    // Closes the Connection
		    JScrollPane scroll = new JScrollPane(table);
		    Container pane = f.getContentPane();
		    top = new JPanel(new BorderLayout());
		    top.add(scroll);
		    bLeft = new JPanel();
		    bLeft.add(left);
		    bRight = new JPanel();
		    bRight.add(right);
		 // Create Action Listener to Button
		    left.addActionListener(new ActionListener(){

				@Override
				public void actionPerformed(ActionEvent arg0) {
					index = (index-1) < 0? (index-1) + queryAry.length:index-1;
					System.out.println(index + " " + queryAry.length);
					PreparedStatement stmt;
					try {
						stmt = con.prepareStatement(queryAry[index]);
						System.out.println(queryAry[index]);
						ResultSet rs = stmt.executeQuery();
						JTable table = new JTable(buildTableModel(rs));
						table.setFillsViewportHeight(true);
						JScrollPane scroll = new JScrollPane(table);
						top.removeAll();
						top.add(scroll);
						f.revalidate();
						f.repaint();
						//f.pack();
					} catch (SQLException e) {
						e.printStackTrace();
					}
				}
		    	
		    });
		    right.addActionListener(new ActionListener(){

				@Override
				public void actionPerformed(ActionEvent arg0) {
					index = (index+1) == queryAry.length? (index+1) % queryAry.length:index+1;
					System.out.println(index + " " + queryAry.length);
					PreparedStatement stmt;
					try {
						stmt = con.prepareStatement(queryAry[index]);
						System.out.println(queryAry[index]);
						ResultSet rs = stmt.executeQuery();
						JTable table = new JTable(buildTableModel(rs));
						table.setFillsViewportHeight(true);
						JScrollPane scroll = new JScrollPane(table);
						top.removeAll();
						top.add(scroll);
						f.revalidate();
						f.repaint();
						//f.pack();
					} catch (SQLException e) {
						e.printStackTrace();
					}
				}
		    	
		    });
		    pane.setLayout(new BorderLayout());
		    pane.add(top,BorderLayout.PAGE_START);
		    pane.add(bLeft,BorderLayout.LINE_START);
		    pane.add(bRight,BorderLayout.LINE_END);
		    f.pack();
		    f.setVisible(true);
		    //JOptionPane.showMessageDialog(null, new JScrollPane(table));
		}
		catch(Exception E){
			System.out.println(E);
		}
	}
	public static DefaultTableModel buildTableModel(ResultSet rs) throws SQLException {

	    ResultSetMetaData metaData = rs.getMetaData();

	    // names of columns
	    Vector<String> columnNames = new Vector<String>();
	    int columnCount = metaData.getColumnCount();
	    for (int column = 1; column <= columnCount; column++) {
	        columnNames.add(metaData.getColumnName(column));
	    }

	    // data of the table
	    Vector<Vector<Object>> data = new Vector<Vector<Object>>();
	    while (rs.next()) {
	        Vector<Object> vector = new Vector<Object>();
	        for (int columnIndex = 1; columnIndex <= columnCount; columnIndex++) {
	            vector.add(rs.getObject(columnIndex));
	        }
	        data.add(vector);
	    }

	    return new DefaultTableModel(data, columnNames);

	}
	public static String getSQLQuery() throws IOException{ //function returns the contents of your .sql query file in a single string
		BufferedReader bfr = new BufferedReader(new FileReader("SQLQuery1.sql"));
		StringBuilder sb = new StringBuilder();
		String line;
		while ((line = bfr.readLine()) != null)
		{
		    sb.append(line);
		}
		bfr.close();
		//System.out.println(sb.toString());
		return sb.toString();
	}
	
}
