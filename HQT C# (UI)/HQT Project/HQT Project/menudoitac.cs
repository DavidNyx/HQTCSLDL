﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HQT_Project
{
    public partial class menudoitac : Form
    {
        public menudoitac()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Hide();
            themsp them = new themsp();
            them.ShowDialog();
            this.Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Hide();
            capnhatsp capnhat = new capnhatsp();
            capnhat.ShowDialog();
            this.Close();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            this.Hide();
            capnhatsl sl = new capnhatsl();
            sl.ShowDialog();
            this.Close();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            this.Hide();
            xoasp xoa = new xoasp();
            xoa.ShowDialog();
            this.Close();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            this.Hide();
            doitactaohopdong xoa = new doitactaohopdong();
            xoa.ShowDialog();
            this.Close();
        }

        private void button6_Click(object sender, EventArgs e)
        {
            this.Hide();
            capnhatdonhang_doitac xoa = new capnhatdonhang_doitac();
            xoa.ShowDialog();
            this.Close();
        }
    }
}
